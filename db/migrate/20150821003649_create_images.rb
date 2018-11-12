class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.references :document_type
      t.references :photo_category
      t.references :imageable, polymorphic: true
      t.integer :image_type, default: 0
      t.string  :name
      t.string  :description
      t.attachment :image
      t.timestamps null: false
    end
    add_index :images, [:imageable_id, :imageable_type]
  end
end
