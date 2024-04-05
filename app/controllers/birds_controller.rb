require 'rest-client'
require 'json'
require 'aws-sdk-s3'

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
  
    @bird = current_user.bird.build(
      user_id: params[:user_id],
      name: params[:name],
      datetime: params[:datetime],
      notes: params[:notes],
      latitude: params[:latitude],
      longitude: params[:longitude]
    )
  
    puts "new bird photo #{@bird}"
  
    url = ENV['FLASK']
    puts "url_photo #{url}"
  
    if uploaded_file.present?
      puts "upload_file"
      s3 = Aws::S3::Resource.new
      bucket = s3.bucket(ENV['S3_BUCKET'])
      object_key = "#{SecureRandom.uuid}"
      obj = bucket.object(object_key)
      puts "obj"
      obj.put(body: uploaded_file.read)
      image_url = obj.public_url
      puts "image_url1 #{obj.public_url}"

      @data = { url: image_url }
      @response = RestClient.post(url, @data.to_json, content_type: :json)
      puts " response photo #{@response}"
      @response_body = @response.body
      @bird.name = @response_body

      puts "@bird.name #{@bird.name}"

      @bird.datetime = Time.now
  
      if blob_field.present?
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
      end
  
      @bird.latitude = latitude
      @bird.longitude = longitude

      @bird.save
  
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
    end
  end

  # def save_photo
  #   uploaded_file = params[:blobb]
  #   blob_field = params[:blob_field]
  #   latitude = params[:latitude]
  #   longitude = params[:longitude]

  #   @bird = current_user.bird.build(user_id: params[:user_id], name: params[:name], datetime: params[:datetime], notes: params[:notes], latitude: params[:latitude], longitude: params[:longitude])

  #   puts "new bird photo #{@bird}"

  #   url = ENV['FLASK']
  #   puts "url_photo #{url}"

  #   if uploaded_file.present?
  #     puts "upload_file"
  #     # File.open(Rails.root.join('tmp', 'uploads', uploaded_file.original_filename), 'wb') do |file|
  #     #   file.write(uploaded_file.read)
  #     # end
  #     s3 = Aws::S3::Resource.new
  #     bucket = s3.bucket(ENV['S3_BUCKET'])
  #     object_key = "#{SecureRandom.uuid}"
  #     obj = bucket.object(object_key)
  #     puts "obj" 
  #     sleep(2)
  #     obj.put(body: uploaded_file.read)
  #     image_url = obj.public_url
  #     puts "image_url1 #{obj.public_url}"

  #     s3_object_url = image_url
  #     puts " s3_object_url photo #{s3_object_url}"
  #     @data = { url: s3_object_url }
  #     @response = RestClient.post(url, @data.to_json, content_type: :json)
  #     puts " response photo #{@response}"
  #     @response_body = @response.body
  
  #     puts "response_body_photo #{@response_body}"
  
  #     @bird_name = @response_body
  #     @bird.name = @bird_name
      


  #   puts "@bird.name!!!!! #{@bird.name}"
  #   puts "image_url2 #{image_url}"

  #   # image_path = Rails.root.join('tmp', 'uploads', 'snapshot.jpeg')
  #   # puts "image_path photo #{image_path}"
  #   # uploader = ImageUploader.new(image_path, ENV['S3_BUCKET'])
    

    
  #   # bucket_name = ENV['S3_BUCKET']
  #   # aws_region = ENV['AWS_REGION']

  #   # s3_object_url = image_url
  #   # puts " s3_object_url photo #{s3_object_url}"
  #   # data = { url: s3_object_url }

  #   # @response = RestClient.post(url, data.to_json, content_type: :json)
  #   # puts " response photo #{@response}"
  #   # @response_body = @response.body

  #   # puts "response_body_photo #{@response_body}"

  #   # @bird.name = @response_body
  #   @bird.datetime = Time.new

  #   base64_data = blob_field.split(',')[1] 
  #   binary_data = Base64.strict_decode64(base64_data)
    
  #   filename = "image_#{Time.current.to_i}.jpg"
  #   content_type = 'image/jpeg'
  #   image_blob = ActiveStorage::Blob.create_and_upload!(
  #     io: StringIO.new(binary_data),
  #     filename: filename,
  #     content_type: content_type
  #   )
    
  #   @bird.image.attach(image_blob)
  #   @bird.latitude = latitude
  #   @bird.longitude = longitude
    
  #   @bird.save


  #   respond_to do |format|
  #     if @bird.save
  #       format.html { redirect_to bird_url(@bird), notice: "Bird was successfully uploaded." }
  #       format.json { render :show, status: :created, location: @bird }
  #     else
  #       format.html { render :new, status: :unprocessable_entity }
  #       format.json { render json: @bird.errors, status: :unprocessable_entity }
  #     end
  #   end

  # end
  # end

  # POST /birds or /birds.json
  def create
    unless current_user
      return redirect_to root_path, alert: "User not found"
    end

    @bird = current_user.bird.build(bird_params)
    puts "new bird create #{@bird}"
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

    puts "url_create #{url}"
    
    bucket_name = ENV['S3_BUCKET']
    aws_region = ENV['AWS_REGION']
    s3_object_url = "https://#{bucket_name}.s3.#{aws_region}.amazonaws.com/#{key}"
    puts " s3_object_url create #{s3_object_url}"
  
    data = { url: s3_object_url }

    @response = RestClient.post(url, data.to_json, content_type: :json)
    puts " response create #{@response}"
    @response_body = @response.body

    puts "response_body_create #{@response_body}"

    @bird.name = @response_body
    @bird.datetime = Time.new

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
