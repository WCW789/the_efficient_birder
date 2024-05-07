# not sure you need this ; it actually broke the app on my laptop when I tried launching it
require 'aws-sdk-s3'

aws_credentials = Rails.application.credentials.dig(:aws)

Aws.config.update(
  region: aws_credentials[:region],
  credentials: Aws::Credentials.new(
    aws_credentials[:access_key_id],
    aws_credentials[:secret_access_key]
  )
)
