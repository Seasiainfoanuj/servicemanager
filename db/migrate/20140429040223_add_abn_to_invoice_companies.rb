class AddAbnToInvoiceCompanies < ActiveRecord::Migration
  def change
    add_column :invoice_companies, :abn, :string
    add_column :invoice_companies, :acn, :string
  end
end
