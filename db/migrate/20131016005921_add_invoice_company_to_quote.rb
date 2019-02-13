class AddInvoiceCompanyToQuote < ActiveRecord::Migration
  def change
    add_column :quotes, :invoice_company_id, :integer
    add_index :quotes, "invoice_company_id"
  end
end
