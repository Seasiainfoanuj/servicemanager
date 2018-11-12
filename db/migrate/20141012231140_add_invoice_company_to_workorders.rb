class AddInvoiceCompanyToWorkorders < ActiveRecord::Migration
  def change
    add_reference :workorders, :invoice_company, index: true
  end
end
