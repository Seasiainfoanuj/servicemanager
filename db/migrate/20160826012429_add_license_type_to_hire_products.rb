class AddLicenseTypeToHireProducts < ActiveRecord::Migration
  def change
    add_column :hire_products, :license_type, :string
  end
end
