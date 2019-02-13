class AddInvoiceCompanyToBuild < ActiveRecord::Migration
  def change
    add_reference :builds, :invoice_company, index: true
  end
end
