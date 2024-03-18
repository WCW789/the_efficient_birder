json.extract! bird, :id, :user_id, :name, :datetime, :notes, :latitude, :longitude, :created_at, :updated_at
json.url bird_url(bird, format: :json)
