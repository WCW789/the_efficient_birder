require 'aws-sdk-s3'

class ImageUploader
  def initialize(image_path, bucket_name)
    @image_path = image_path
    @bucket_name = bucket_name
  end

  def upload(blob_field)
    s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
    filename = File.basename(@image_path)
    object_key = generate_object_key(filename)

    blob_hash = Digest::SHA256.hexdigest(blob_field)
    obj = s3.bucket(@bucket_name).object(object_key).put(
      body: blob_field,
    )
    obj.upload_file(@image_path)
    obj.wait_until_exists
    obj.public_url
  end

  def generate_object_key(filename)
    extension = File.extname(filename).downcase
    "#{SecureRandom.uuid}#{extension}"
  end
end
