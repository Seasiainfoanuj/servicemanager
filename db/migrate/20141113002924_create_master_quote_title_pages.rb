class CreateMasterQuoteTitlePages < ActiveRecord::Migration
  def change
    create_table :master_quote_title_pages do |t|
      t.belongs_to :master_quote, index: true
      t.string :title
      t.attachment :image_1
      t.attachment :image_2
      t.timestamps
    end
  end
end
