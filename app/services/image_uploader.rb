require 'aws-sdk-s3'

class ImageUploader
  def initialize(image_path, bucket_name)
    @image_path = image_path
    @bucket_name = bucket_name
  end

  def upload
    s3 = Aws::S3::Resource.new
    bucket = s3.bucket(@bucket_name)
    filename = File.basename(@image_path)
    object_key = generate_object_key(filename)
    obj = bucket.object(object_key)
    obj.upload_file(@image_path)
    obj.public_url
  end

  def generate_object_key(filename)
    extension = File.extname(filename).downcase
    "#{SecureRandom.uuid}#{extension}"
  end
end
