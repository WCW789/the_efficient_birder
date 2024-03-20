# == Schema Information
#
# Table name: birds
#
#  id         :bigint           not null, primary key
#  datetime   :datetime
#  latitude   :float
#  longitude  :float
#  name       :string
#  notes      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_birds_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Bird < ApplicationRecord
  belongs_to :user
  has_many_attached :image

  validate :acceptable_image

  def acceptable_image
    return unless image.attached?

    image.each do |img|
      if img.blob.byte_size > 10.megabytes
        errors.add(:img, "is too big")
      end
    end

    acceptable_types = ["image/jpeg", "image/gif", "image/png"]
    image.each do |img|
      unless acceptable_types.include?(img.content_type)
        errors.add(:img, "must be a JPEG, GIF, or PNG")
      end
    end
  end

end
