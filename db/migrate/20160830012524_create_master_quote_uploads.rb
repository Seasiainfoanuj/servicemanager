class CreateMasterQuoteUploads < ActiveRecord::Migration
  def change
    create_table :master_quote_uploads do |t|
      t.belongs_to :master_quote, index: true
      t.attachment :upload
      t.timestamps null: false
    end
  end
end
