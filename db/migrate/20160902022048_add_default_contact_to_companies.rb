class AddDefaultContactToCompanies < ActiveRecord::Migration
  def change
    add_reference :companies, :default_contact
  end
end
