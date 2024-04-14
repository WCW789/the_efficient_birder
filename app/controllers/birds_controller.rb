require 'rest-client'
require 'json'
require 'uri'
require 'net/http'
require 'cgi'
require 'active_support/all'

class BirdsController < ApplicationController
  # include ApplicationHelper

  before_action :authenticate_user!
  before_action :set_bird, only: %i[ show edit update destroy ]

  # GET /birds or /birds.json
  def index
    @birds = Bird.all
  end

  def export
    @birds = Bird.all

    # render birds_export_path

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
  end

  # GET /birds/new
  def new
    @bird = Bird.new
    @bird.image.build
  end

  # GET /birds/1/edit
  def edit
  end

  def take_photo
    render birds_photo_path
  end

  def save_photo
    uploaded_file = params[:blobb]
    blob_field = params[:blob_field]
    latitude = params[:latitude]
    longitude = params[:longitude]

    if uploaded_file.present?
      File.open(Rails.root.join('public', 'uploads', uploaded_file.original_filename), 'wb') do |file|
        file.write(uploaded_file.read)
      end
    end

    image_path = Rails.root.join('public', 'uploads', 'snapshot.jpeg')
    uploader = ImageUploader.new(image_path, ENV['S3_BUCKET'])
    
    @bird = current_user.bird.build(user_id: params[:user_id], name: params[:name], datetime: params[:datetime], notes: params[:notes], latitude: params[:latitude], longitude: params[:longitude])
    
    respond_to do |format|
      if @bird.save
        format.html { redirect_to bird_url(@bird), notice: "Bird was successfully uploaded." }
        format.json { render :show, status: :created, location: @bird }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @bird.errors, status: :unprocessable_entity }
      end
    end

    url = ENV['FLASK']
    bucket_name = ENV['S3_BUCKET']
    aws_region = ENV['AWS_REGION']

    s3_object_url = uploader.upload()
    data = { url: s3_object_url }

    @response = RestClient.post(url, data.to_json, content_type: :json)
    @response_body = @response.body

    puts "response_body_photo #{@response_body}"

    @bird.name = @response_body

    utc_datetime_string = Time.new.to_s
    utc_datetime = DateTime.strptime(utc_datetime_string, "%Y-%m-%d %H:%M:%S %z")
    local_datetime = utc_datetime.in_time_zone(ActiveSupport::TimeZone['Central Time (US & Canada)'])
    formatted_datetime = local_datetime.strftime("%B-%-d-%Y %H:%M")
    @bird.datetime = formatted_datetime

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
    @bird.latitude = latitude
    @bird.longitude = longitude
    
    @bird.save
  end

  def take_camera
    render birds_camera_path
  end

  def save_camera
    unless current_user
      return redirect_to root_path, alert: "User not found"
    end

    images = params[:image]
    latitude = params[:latitude]
    longitude = params[:longitude]

    if params[:image].present?
      filename = "snapshot.jpeg"

      File.open(Rails.root.join('public', 'uploads', filename), 'wb') do |file|
        file.write(params[:image].read)
      end
    end

    image_path = Rails.root.join('public', 'uploads', 'snapshot.jpeg')
    uploader = ImageUploader.new(image_path, ENV['S3_BUCKET'])

    @bird = current_user.bird.build(user_id: params[:user_id], name: params[:name], datetime: params[:datetime], notes: params[:notes], latitude: params[:latitude], longitude: params[:longitude])

    respond_to do |format|
      if @bird.save
        format.html { redirect_to bird_url(@bird), notice: "Bird was successfully uploaded." }
        format.json { render :show, status: :created, location: @bird }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @bird.errors, status: :unprocessable_entity }
      end
    end

    url = ENV['FLASK']
    bucket_name = ENV['S3_BUCKET']
    aws_region = ENV['AWS_REGION']

    s3_object_url = uploader.upload()
    data = { url: s3_object_url }

    @response = RestClient.post(url, data.to_json, content_type: :json)
    @response_body = @response.body
    
    puts "response_body_camera #{@response_body}"

    @bird.name = @response_body
    @bird.datetime = Time.new

    content_type = params[:image].content_type

    image_blob = ActiveStorage::Blob.create_and_upload!(
      io: params[:image].open,
      filename: filename,
      content_type: content_type
    )

    @bird.image.attach(image_blob)
    @bird.latitude = latitude
    @bird.longitude = longitude
    
    @bird.save
  end


  # POST /birds or /birds.json
  def create
    unless current_user
      return redirect_to root_path, alert: "User not found"
    end

    @bird = current_user.bird.build(bird_params)
    key = nil

    respond_to do |format|
      if @bird.save
        key = @bird.image.first.key
        format.html { redirect_to bird_url(@bird), notice: "Bird was successfully created." }
        format.json { render :show, status: :created, location: @bird }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @bird.errors, status: :unprocessable_entity }
      end
    end

    url = ENV['FLASK']
    bucket_name = ENV['S3_BUCKET']
    aws_region = ENV['AWS_REGION']
    s3_object_url = "https://#{bucket_name}.s3.#{aws_region}.amazonaws.com/#{key}"
  
    data = { url: s3_object_url }

    @response = RestClient.post(url, data.to_json, content_type: :json)
    @response_body = @response.body

    puts "response_body_create #{@response_body}"

    @bird.name = @response_body

    datetime_string = @bird.datetime.to_s
    datetime = DateTime.strptime(datetime_string, "%Y-%m-%d %H:%M:%S %z")
    formatted_datetime = datetime.strftime("%B-%-d-%Y %H:%M")
    @bird.datetime = formatted_datetime 

    address_params = params[:bird][:address]
    address = CGI.escape(address_params)

    url = URI("https://api.mapbox.com/geocoding/v5/mapbox.places/#{address}.json?access_token=#{ENV['MAPBOX']}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url)
    response = http.request(request)
    
    if response.code == "200"
      response_body = JSON.parse(response.body)
      center = response_body["features"].first["center"]
      @bird.longitude = center[0]
      @bird.latitude = center[1]
    else
      puts "Error"
    end

    @bird.notes = "#{@bird.notes} (Bird seen at #{address_params})"
    @bird.save
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
