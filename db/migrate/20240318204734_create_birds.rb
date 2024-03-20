class CreateBirds < ActiveRecord::Migration[7.0]
  def change
    create_table :birds do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.datetime :datetime
      t.text :notes
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
