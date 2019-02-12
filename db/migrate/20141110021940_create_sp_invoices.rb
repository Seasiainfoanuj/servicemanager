class CreateSpInvoices < ActiveRecord::Migration
  def change
    create_table :sp_invoices do |t|
      t.references :job, index: true, polymorphic: true
      t.string :invoice_number
      t.string :status
      t.attachment :upload
      t.timestamps
    end
  end
end
