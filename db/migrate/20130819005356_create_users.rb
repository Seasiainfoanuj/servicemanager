class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string "first_name", :limit => 50
      t.string "last_name", :limit => 50
      t.string "phone"
      t.string "fax"
      t.string "mobile"
      t.datetime "dob"
      t.string "company"
      t.string "job_title"
      t.text "notes"
      t.timestamps
    end
  end
end
