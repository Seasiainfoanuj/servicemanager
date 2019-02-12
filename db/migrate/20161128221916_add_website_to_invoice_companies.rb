class AddWebsiteToInvoiceCompanies < ActiveRecord::Migration
  def change
    add_column :invoice_companies, :website, :string
  end
end
