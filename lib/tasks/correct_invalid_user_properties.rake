namespace :users do
  desc "Correct invalid user properties"
  task :correct_invalid_properties => :environment do
    invalid_users_count = 0
    corrected_count = 0
    User.all.each do |user|
      error_found = false
      print "\nUser #{user.id}"
      if user.valid?
        print " OK"
      else
        print " INVALID "  
        if user.first_name.blank?
          error_found = true
          print '.'
          user.first_name = 'UNKNOWN'
        end
        if user.first_name.length > 40
          error_found = true
          print '.'
          user.first_name = user.first_name[0..39]
        end  
        if user.first_name.length < 2
          error_found = true
          print '.'
          user.first_name += " INVALID"
        end
        if user.last_name.blank?
          error_found = true
          print '.'
          user.last_name = 'UNKNOWN'
        end
        if user.last_name.length > 40
          error_found = true
          print '.'
          user.last_name = user.last_name[0..39]
        end  
        if user.last_name.length < 2
          error_found = true
          print '.'
          user.last_name += " INVALID"
        end
        if user.phone.present?
          if user.phone.length < 8
            error_found = true
            print '.'
            user.phone = "INVALID " + user.phone
          elsif user.phone.length > 20
            error_found = true
            print '.'
            user.phone = user.phone[0..19]
          end
        end    
        if user.mobile.present?
          if user.mobile.length < 10
            error_found = true
            print '.'
            user.mobile = "INVALID " + user.mobile
          elsif user.mobile.length > 20
            error_found = true
            print '.'
            user.mobile = user.mobile[0..19]
          end
        end    
        if user.fax.present?
          if user.fax.length < 8
            error_found = true
            print '.'
            user.fax = "INVALID " + user.fax
          elsif user.fax.length > 20
            error_found = true
            print '.'
            user.fax = user.fax[0..19]
          end
        end
        if user.roles.include?(:customer) && user.roles.include?(:quote_customer)
          user.roles.delete(:quote_customer)
        end
        if user.roles.count > 1 && user.roles.include?(:admin)
          user.roles = [:admin]
        end    
        if user.valid? && user.client.blank?
          user.build_client(client_type: "person")
          user.save!
          corrected_count += 1
          print ' corrected'
        else
          invalid_users_count += 1
          puts user.inspect
        end 
      end
    end    
    puts "\nTotal invalid users: #{invalid_users_count}"    
    puts "\nTotal corrected users: #{corrected_count}"    
  end
end    

