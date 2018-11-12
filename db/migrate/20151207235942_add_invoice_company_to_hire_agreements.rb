class AddInvoiceCompanyToHireAgreements < ActiveRecord::Migration
  def change
    add_reference :hire_agreements, :invoice_company, index: true
  end
end
