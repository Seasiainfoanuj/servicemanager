class CreateQuoteSummaryPages < ActiveRecord::Migration
  def change
    create_table :quote_summary_pages do |t|
      t.references :quote, index: true
      t.text :text

      t.timestamps
    end
  end
end
