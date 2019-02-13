class ChangeHireAgreementNotesToDetails < ActiveRecord::Migration
  def change
    rename_column :hire_agreements, :notes, :details
  end
end
