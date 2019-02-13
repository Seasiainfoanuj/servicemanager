class AddAccountsAdminToInvoiceCompanies < ActiveRecord::Migration
  def change
    add_reference :invoice_companies, :accounts_admin, index: true
  end
end
