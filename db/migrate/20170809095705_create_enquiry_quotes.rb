class CreateEnquiryQuotes < ActiveRecord::Migration
  def change
    create_table :enquiry_quotes do |t|

      t.timestamps null: false
    end
  end
end
