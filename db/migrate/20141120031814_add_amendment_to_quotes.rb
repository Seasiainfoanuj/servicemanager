class AddAmendmentToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :amendment, :boolean, default: false
  end
end
