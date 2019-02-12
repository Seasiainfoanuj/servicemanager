class CreateHireAgreementTypeUploads < ActiveRecord::Migration
  def change
    create_table :hire_agreement_type_uploads do |t|
      t.references :hire_agreement_type, index: true
      t.attachment :upload
      t.timestamps
    end
  end
end
