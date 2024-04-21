module AddingImages
  extend ActiveSupport::Concern

  included do
    has_many_attached :image
    validate :acceptable_image
  end

  def image_attributes=(image_attributes)
    image_attributes.each do |i, image_attributes|
      self.image.attach(image_attributes[:image])
    end
  end

  def acceptable_image
    return unless image.attached?

    acceptable_types = ["image/jpeg", "image/gif", "image/png"]

    image.each do |img|
      if img.blob.byte_size > 10.megabytes
        errors.add(:img, "is too big")
      elsif !acceptable_types.include?(img.content_type)
        errors.add(:img, "must be a JPEG, GIF, or PNG")
      end
    end
  end
end
