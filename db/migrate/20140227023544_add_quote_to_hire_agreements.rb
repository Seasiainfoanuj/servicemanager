class AddQuoteToHireAgreements < ActiveRecord::Migration
  def change
    add_column :hire_agreements, :quote_id, :integer
    add_index :hire_agreements, :quote_id
  end
end
