class ChangeQuoteNotesToComments < ActiveRecord::Migration
  def change
    rename_column :quotes, :notes, :comments
  end
end
