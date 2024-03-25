require 'aws-sdk-s3'

aws_credentials = Rails.application.credentials.dig(:aws)

Aws.config.update(
  region: aws_credentials[:region],
  credentials: Aws::Credentials.new(
    aws_credentials[:access_key_id],
    aws_credentials[:secret_access_key]
  )
)
