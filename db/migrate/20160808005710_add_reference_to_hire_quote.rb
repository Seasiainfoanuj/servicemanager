class AddReferenceToHireQuote < ActiveRecord::Migration
  def change
    add_column :hire_quotes, :reference, :string
    add_index :hire_quotes, :reference
  end
end
