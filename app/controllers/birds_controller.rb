# are these necessary?
require 'rest-client'
require 'json'
require 'uri'
require 'net/http'
require 'cgi'
require 'active_support/all'

# this controller has a lot going on, it could be refactored into services or concerns
class BirdsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_bird, only: %i[ show edit update destroy ]

  # GET /birds or /birds.json
  def index
    @birds = current_user.bird.includes(:image_attachments)

    @q = @birds.ransack(params[:q])
    @sorts = @q.result(distinct: true)
    @sorted_entries = @sorts.order(datetime: :desc, name: :asc)
    @birds = @sorted_entries.page(params[:page]).per(5)
  end

  def export
    # Functionality in progress
    @birds = Bird.all

    respond_to do |format|
      format.html
      format.pdf do
        pdf_html = ActionController::Base.new.render_to_string(template: 'birds/export', layout: false)
        pdf = WickedPdf.new.pdf_from_string(pdf_html)
        send_data pdf, filename: 'birding_journal.pdf'
      end
    end
  end

  # GET /birds/1 or /birds/1.json
  def show
    @bird = Bird.find(params[:id])
    authorize @bird

    rescue Pundit::NotAuthorizedError
    redirect_to root_path, alert: "Not Authorized to View"
  end

  # GET /birds/new
  def new
    @bird = Bird.new
    @bird.image.build
  end

  # GET /birds/1/edit
  def edit
    @bird = Bird.find(params[:id])
    authorize @bird

    rescue Pundit::NotAuthorizedError
    redirect_to root_path, alert: "Not Authorized to View"
  end
  # take_photo and save_photo could be concerned out
  def take_photo
    render birds_photo_path
  end
  # a more OOP approach could simplify this method and make it more readable
  def save_photo
    uploaded_file = params[:blobb]
    blob_field = params[:blob_field]
    latitude = params[:latitude]
    longitude = params[:longitude]

    # Moving image to a temporary file in public/uploads
    if uploaded_file.present?
      File.open(Rails.root.join('public', 'uploads', uploaded_file.original_filename), 'wb') do |file|
        file.write(uploaded_file.read)
      end
    end
    image_path = Rails.root.join('public', 'uploads', 'snapshot.jpeg')

    # ImageUploader service generates object url
    uploader = ImageUploader.new(image_path, ENV['S3_BUCKET'])

    # Using Flask server for classification
    url = ENV['FLASK']

    # Get object url from ImageUploader service and send to Flask. Server responds with name
    s3_object_url = uploader.upload()
    data = { url: s3_object_url }
    @response = RestClient.post(url, data.to_json, content_type: :json)
    @response_body = @response.body
    @bird = current_user.bird.build(user_id: params[:user_id], name: params[:name], datetime: params[:datetime], notes: params[:notes], latitude: params[:latitude], longitude: params[:longitude])
    @bird.name = @response_body

    # Get datetime
    photo_datetime()

    # Send BLOB data to ActiveStorage
    base64_data = blob_field.split(',')[1]
    binary_data = Base64.strict_decode64(base64_data)
    filename = "image_#{Time.current.to_i}.jpg"
    content_type = 'image/jpeg'
    image_blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(binary_data),
      filename: filename,
      content_type: content_type
    )
    @bird.image.attach(image_blob)

    # Get location data from params
    @bird.latitude = latitude
    @bird.longitude = longitude

    @bird.save

    respond_to do |format|
      if @bird.save
        format.html { redirect_to bird_url(@bird), notice: "Bird was successfully uploaded" }
        format.json { render :show, status: :created, location: @bird }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @bird.errors, status: :unprocessable_entity }
      end
    end
  end

  def photo_datetime
    utc_datetime_string = Time.new.to_s
    utc_datetime = DateTime.strptime(utc_datetime_string, "%Y-%m-%d %H:%M:%S %z")
    local_datetime = utc_datetime.in_time_zone(ActiveSupport::TimeZone['Central Time (US & Canada)'])
    formatted_datetime = local_datetime.strftime("%B-%-d-%Y %H:%M")
    @bird.datetime = formatted_datetime
  end

  def take_camera # naming could be more explicit. not sure what it does
    render birds_camera_path
  end

  def save_camera # naming could be more explicit. not sure what it does
    unless current_user
      return redirect_to root_path, alert: "User not found"
    end

    latitude = params[:latitude]
    longitude = params[:longitude]
    @bird = current_user.bird.build(user_id: params[:user_id], name: params[:name], datetime: params[:datetime], notes: params[:notes], latitude: params[:latitude], longitude: params[:longitude])

    if params[:image].present?
      filename = "snapshot.jpeg"

      # Moving image to a temporary file in public/uploads
      File.open(Rails.root.join('public', 'uploads', filename), 'wb') do |file|
        file.write(params[:image].read)
      end
    end
    image_path = Rails.root.join('public', 'uploads', 'snapshot.jpeg')

    # ImageUploader service generates object url
    uploader = ImageUploader.new(image_path, ENV['S3_BUCKET'])

    # Using Flask server for classification
    url = ENV['FLASK']

    # Get object url from ImageUploader service and send to Flask. Server responds with name
    s3_object_url = uploader.upload()
    data = { url: s3_object_url }
    @response = RestClient.post(url, data.to_json, content_type: :json)
    @response_body = @response.body
    @bird.name = @response_body

     # Send BLOB data to ActiveStorage
    content_type = params[:image].content_type
    image_blob = ActiveStorage::Blob.create_and_upload!(
      io: params[:image].open,
      filename: filename,
      content_type: content_type
    )
    @bird.image.attach(image_blob)

    # Get current datetime
    photo_datetime()

    # Get location data from params
    @bird.latitude = latitude
    @bird.longitude = longitude

    @bird.save

    respond_to do |format|
      if @bird.save
        format.html { redirect_to bird_url(@bird), notice: "Bird was successfully uploaded" }
        format.json { render :show, status: :created, location: @bird }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @bird.errors, status: :unprocessable_entity }
      end
    end
  end


  # POST /birds or /birds.json
  def create #currently refactoring and making the steps to get bird name into a service
    unless current_user
      return redirect_to root_path, alert: "User not found"
    end

    @bird = current_user.bird.build(bird_params)

    # key is the string at the end of the S3 object url
    key = nil

    respond_to do |format|
      if @bird.save
        key = @bird.image.first.key
        format.html { redirect_to bird_url(@bird), notice: "Bird was successfully created" }
        format.json { render :show, status: :created, location: @bird }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @bird.errors, status: :unprocessable_entity }
      end
    end

    # Using Flask server for classification
    url = ENV['FLASK']

    bucket_name = ENV['S3_BUCKET']
    aws_region = ENV['AWS_REGION']
    s3_object_url = "https://#{bucket_name}.s3.#{aws_region}.amazonaws.com/#{key}"

    # Sending to server to get bird name
    data = { url: s3_object_url }
    @response = RestClient.post(url, data.to_json, content_type: :json)
    @response_body = @response.body
    @bird.name = @response_body

    # Get datetime of image upload
    upload_datetime()

    # Get coordinates from address
    address_params = params[:bird][:address]
    geolocator = Geolocation.new(address_params)
    mapping = geolocator.mapping()
    @bird.longitude = mapping[0]
    @bird.latitude = mapping[1]

    # Save address in notes
    @bird.notes = "#{@bird.notes} (Bird seen at #{address_params})"

    @bird.save
  end

  def upload_datetime
    datetime_string = @bird.datetime.to_s
    datetime = DateTime.strptime(datetime_string, "%Y-%m-%d %H:%M:%S %z")
    formatted_datetime = datetime.strftime("%B-%-d-%Y %H:%M")
    @bird.datetime = formatted_datetime
  end

  # PATCH/PUT /birds/1 or /birds/1.json
  def update
    @bird = Bird.find(params[:id])
    respond_to do |format|
      if @bird.update(bird_params)
        format.html { redirect_to bird_url(@bird), notice: "Bird was successfully updated." }
        format.json { render :show, status: :ok, location: @bird }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @bird.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /birds/1 or /birds/1.json
  def destroy
    @bird.destroy

    respond_to do |format|
      format.html { redirect_to birds_url, notice: "Bird was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bird
      @bird = Bird.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def bird_params
      params.require(:bird).permit(:user_id, :name, :datetime, :notes, :latitude, :longitude, image_attributes: [:image])
    end
end
