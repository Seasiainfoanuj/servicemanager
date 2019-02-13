class CreateQuoteTitlePages < ActiveRecord::Migration
  def change
    create_table :quote_title_pages do |t|
      t.belongs_to :quote, index: true
      t.string :title
      t.attachment :image_1
      t.attachment :image_2
      t.timestamps
    end
  end
end
