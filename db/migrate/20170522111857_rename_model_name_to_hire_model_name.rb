class RenameModelNameToHireModelName < ActiveRecord::Migration
  def change
    rename_column :hire_addons, :model_name, :hire_model_name
  end
end
