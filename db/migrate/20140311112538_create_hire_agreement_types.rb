class CreateHireAgreementTypes < ActiveRecord::Migration
  def change
    create_table :hire_agreement_types do |t|
      t.string "name"
      t.decimal "damage_recovery_fee", :precision => 8, :scale => 2
      t.decimal "fuel_service_fee", :precision => 8, :scale => 2
      t.timestamps
    end

    add_column :hire_agreements, :hire_agreement_type_id, :integer
    add_index :hire_agreements, :hire_agreement_type_id
  end
end
