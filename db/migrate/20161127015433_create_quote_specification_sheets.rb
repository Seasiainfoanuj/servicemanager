class CreateQuoteSpecificationSheets < ActiveRecord::Migration
  def change
    create_table :quote_specification_sheets do |t|
      t.belongs_to :quote, index: true
      t.attachment :upload

      t.timestamps
    end
  end
end
