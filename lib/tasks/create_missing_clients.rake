namespace :users do
  desc "Create Client records for users without clients"
  task :create_missing_clients => :environment do
    missing_clients_count = 0
    error_count = 0

    User.all.each do |user|
      if user.client.blank?
        missing_clients_count += 1
        client = Client.create!(
          user_id: user.id,
          client_type: "person",
          archived_at: user.archived_at)
        user.client_reference = client.reference_number
        if user.valid?
          user.save
        else
          puts "Invalid user: #{user.inspect}"
          error_count += 1
        end    
      end  
    end
    puts "Total missing clients: #{missing_clients_count}"
    puts "Errors found: #{error_count}"
  end
end      
