class CreateHireEnquiry < ActiveRecord::Migration
  def change
    create_table :hire_enquiries do |t|
      t.references :enquiry, index: true
      t.date :hire_start_date
      t.string :duration_unit
      t.integer :units
      t.integer :number_of_vehicles
      t.boolean :delivery_required, default: false
      t.string :delivery_location
      t.boolean :ongoing_contract, default: false
      t.string :transmission_preference, default: 'No Preference'
      t.integer :minimum_seats, default: 0
      t.string :special_requirements
    end
  end
end
