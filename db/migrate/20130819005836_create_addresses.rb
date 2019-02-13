class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.references :user
      t.string "line_1"
      t.string "line_2"
      t.string "suburb"
      t.string "state"
      t.string "postcode"
      t.string "country"
      t.timestamps
    end
    add_index("addresses", "user_id")
  end
end
