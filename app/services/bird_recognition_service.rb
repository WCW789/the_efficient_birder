require 'rest-client'

class BirdRecognitionService
  def initialize(key)
    @key = key
    puts "key #{@key}"
  end

  def call
    url = '127.0.0.1:5000/bird' || ENV['FLASK']

    puts "url_create #{url}"
    
    bucket_name = ENV['S3_BUCKET']
    aws_region = ENV['AWS_REGION']
    s3_object_url = "https://#{bucket_name}.s3.#{aws_region}.amazonaws.com/#{@key}"
    puts "s3_object_url: #{s3_object_url}"
    data = { url: s3_object_url }
    puts "data: #{data}"
    @response = RestClient.post(url, data.to_json, content_type: :json)
    puts "response: #{@response}"
    
    return @response.body
  rescue => e
    puts "An error occurred in BirdsController#create: #{e}"
  end
end
