class CreateMasterQuoteSpecificationSheets < ActiveRecord::Migration
  def change
    create_table :master_quote_specification_sheets do |t|
      t.belongs_to :master_quote, index: true
      t.attachment :upload

      t.timestamps
    end
  end
end
