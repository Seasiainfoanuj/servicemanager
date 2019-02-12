class CreateQuoteUploads < ActiveRecord::Migration
  def change
    create_table :quote_uploads do |t|
      t.belongs_to :quote, index: true
      t.attachment :upload
      t.timestamps
    end
  end
end
