class AddDemurrageFieldsToHireAgreement < ActiveRecord::Migration
  def change
    add_column :hire_agreements, :demurrage_start_time, :datetime
    add_column :hire_agreements, :demurrage_end_time, :datetime
    add_column :hire_agreements, :demurrage_rate, :decimal, :precision => 8, :scale => 2
  end
end
