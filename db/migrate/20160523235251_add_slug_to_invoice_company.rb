class AddSlugToInvoiceCompany < ActiveRecord::Migration
  def change
    add_column :invoice_companies, :slug, :string
  end
end
