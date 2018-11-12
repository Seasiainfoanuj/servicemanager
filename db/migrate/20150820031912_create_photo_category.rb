class CreatePhotoCategory < ActiveRecord::Migration
  def change
    create_table :photo_categories do |t|
      t.string :name
      t.timestamps null: false
    end
  end
end
