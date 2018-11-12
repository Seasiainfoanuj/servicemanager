class AddFlaggedToEnquiry < ActiveRecord::Migration
  def change
    add_column :enquiries, :flagged, :boolean
  end
end
