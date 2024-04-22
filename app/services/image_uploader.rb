require 'aws-sdk-s3'

class ImageUploader
  def initialize(image_path, bucket_name)
    @image_path = image_path
    @bucket_name = bucket_name
  end

  def upload
    s3 = Aws::S3::Resource.new
    bucket = s3.bucket(@bucket_name)
    object_key = "#{SecureRandom.uuid}"
    obj = bucket.object(object_key)
    sleep(3)
    obj.upload_file(@image_path)
    obj.wait_until_exists
    obj.public_url
  end
end
