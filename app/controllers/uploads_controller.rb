class UploadsController < ApplicationController
  def show
    video_path = Rails.root.join('public', 'uploads', 'TestVideo.mp4')
    send_file video_path, type: 'video/mp4'
  end
end
