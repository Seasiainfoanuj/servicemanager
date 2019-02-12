class CreateSearchTags < ActiveRecord::Migration
  def change
    create_table :search_tags do |t|
      t.string :tag_type
      t.string :name
    end
    add_index :search_tags, [:tag_type, :name], unique: true
  end
end
