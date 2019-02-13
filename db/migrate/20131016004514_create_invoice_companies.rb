class CreateInvoiceCompanies < ActiveRecord::Migration
  def change
    create_table :invoice_companies do |t|
      t.string "name"
      t.string "phone"
      t.string "fax"
      t.string "address_line_1"
      t.string "address_line_2"
      t.string "suburb"
      t.string "state"
      t.string "postcode"
      t.string "country"
      t.timestamps
    end
  end
end
