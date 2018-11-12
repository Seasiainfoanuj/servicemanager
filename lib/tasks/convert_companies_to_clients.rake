namespace :companies do
  desc "Convert all companies to clients"
  task :convert_to_client => :environment do
    clients_count = Client.count
    error_count = 0
    puts "Client count before loading client records: #{clients_count}"

    Company.all.each do |company|
      company.build_client(client_type: "company")
      if company.valid?
        company.save
        clients_count += 1
      else
        puts "Invalid company: #{company.id}, #{company.name}"
        error_count += 1
      end  
    end

    puts "Client count after loading client records: #{clients_count}"
    puts "Company count for invalid companies: #{error_count}"
    puts "Client.count: #{Client.count}"

  end
end    
