# == Schema Information
#
# Table name: images
#
#  id         :bigint           not null, primary key
#  image      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  bird_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_images_on_bird_id  (bird_id)
#  index_images_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (bird_id => birds.id)
#  fk_rails_...  (user_id => users.id)
#
class Image < ApplicationRecord
end
