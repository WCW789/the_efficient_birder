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
  include Imageable

  def self.ransackable_attributes(auth_object = nil)
    ["datetime", "name"]
  end
end
