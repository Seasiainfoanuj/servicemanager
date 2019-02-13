class CreateLicences < ActiveRecord::Migration
  def change
    create_table :licences do |t|
      t.references :user, index: true
      t.string :number
      t.string :state_of_issue
      t.date :expiry_date
      t.attachment :upload
      t.timestamps
    end
  end
end
