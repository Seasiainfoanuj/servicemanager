class AddInvoiceCompanyToEnquiries < ActiveRecord::Migration
  def change
    add_reference :enquiries, :invoice_company, index: true
  end
end
