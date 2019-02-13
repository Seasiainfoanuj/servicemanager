class CreateMasterQuoteSummaryPages < ActiveRecord::Migration
  def change
    create_table :master_quote_summary_pages do |t|
      t.references :master_quote, index: true
      t.text :text

      t.timestamps
    end
  end
end
