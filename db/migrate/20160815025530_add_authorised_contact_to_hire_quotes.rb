class AddAuthorisedContactToHireQuotes < ActiveRecord::Migration
  def change
    add_reference :hire_quotes, :authorised_contact, index: true
  end
end
