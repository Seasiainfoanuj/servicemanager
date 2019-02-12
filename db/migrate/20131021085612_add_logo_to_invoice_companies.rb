class AddLogoToInvoiceCompanies < ActiveRecord::Migration
  def change
    add_attachment :invoice_companies, :logo
  end
end
