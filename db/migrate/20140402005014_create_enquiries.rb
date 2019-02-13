class CreateEnquiries < ActiveRecord::Migration
  def change
    create_table :enquiries do |t|
      t.belongs_to :enquiry_type, index: true
      t.belongs_to :user, index: true
      t.belongs_to :manager, index: true
      t.string :uid
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.string :company
      t.string :job_title
      t.text :details
      t.timestamps
    end

    add_index("enquiries", "uid")
  end
end
