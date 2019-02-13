namespace :reorg_addresses do

  desc "Assign Address Owners"
  task "assign_address_owners" => :environment do
    invalid_user_count = 0
    valid_user_count = 0
    invalid_enquiry_count = 0
    valid_enquiry_count = 0
    Address.all.each do |addr|
      if addr.user_id.present?
        if User.exists?(addr.user_id)
          addr.addressable_id = addr.user_id
          addr.addressable_type = 'User'
          addr.save!
          valid_user_count += 1
        else
          invalid_user_count += 1
        end
      else
        if Enquiry.exists?(addr.enquiry_id)
          addr.addressable_id = addr.enquiry_id
          addr.addressable_type = 'Enquiry'
          addr.save!
          valid_enquiry_count += 1
        else
          invalid_enquiry_count += 1
        end
      end
    end
    puts "Addresses belonging to valid users: #{valid_user_count}"
    puts "Addresses belonging to invalid users: #{invalid_user_count}"
    puts "Addresses belonging to valid enquiries: #{valid_enquiry_count}"
    puts "Addresses belonging to invalid enquiries: #{invalid_enquiry_count}"
  end
end