require 'rest-client'
require 'json'

class BirdsController < ApplicationController
  # include ApplicationHelper

  before_action :authenticate_user!
  before_action :set_bird, only: %i[ show edit update destroy ]

  # GET /birds or /birds.json
  def index
    @birds = Bird.all
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

    if uploaded_file.present?

      File.open(Rails.root.join('public', 'uploads', uploaded_file.original_filename), 'wb') do |file|
        file.write(uploaded_file.read)
      end
    end

    image_path = Rails.root.join('public', 'uploads', 'snapshot.jpeg')
    uploader = ImageUploader.new(image_path, ENV['S3_BUCKET'])
    @image_url = uploader.upload
    puts "The image URL: " + @image_url
  end

  # POST /birds or /birds.json
  # def upload
  # end

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

    url = 'http://127.0.0.1:5000/bird'

    bucket_name = ENV['S3_BUCKET']
    aws_region = ENV['AWS_REGION']
    s3_object_url = "https://#{bucket_name}.s3.#{aws_region}.amazonaws.com/#{key}"
  
    data = { url: s3_object_url }.to_json

    @response = RestClient.post(url, data.to_json, content_type: :json)

    @reponse_body = @response.body
  
    puts "Look right here: " + @reponse_body

    @bird.name = @reponse_body
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
