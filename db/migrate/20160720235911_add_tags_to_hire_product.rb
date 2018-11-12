class AddTagsToHireProduct < ActiveRecord::Migration
  def change
    add_column :hire_products, :tags, :string
  end
end
