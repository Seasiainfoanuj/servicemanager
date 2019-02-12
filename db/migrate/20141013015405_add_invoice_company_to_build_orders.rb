class AddInvoiceCompanyToBuildOrders < ActiveRecord::Migration
  def change
    add_reference :build_orders, :invoice_company, index: true
  end
end
