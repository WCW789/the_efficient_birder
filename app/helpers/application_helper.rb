module ApplicationHelper
  def s3_object_keys(bucket_name)
    s3 = Aws::S3::Resource.new
    bucket = s3.bucket(bucket_name)
    last_object_key = bucket.objects.sort_by(&:last_modified).map(&:key)
    last_object_key.last
  end
end
