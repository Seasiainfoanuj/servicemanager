class AddQuotedDateToHireQuotes < ActiveRecord::Migration
  def change
    add_column :hire_quotes, :quoted_date, :date
  end
end
