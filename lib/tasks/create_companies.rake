namespace :create_companies do

  desc "Extract company record from User.company field"
  task "extract_company_records" => :environment do
    company_count = 0
    duplicate_company_count = 0
    address_count = 0

    User.all.each do |user|
      if Company.exists?(name: user.company)
        company = Company.find_by(name: user.company)
        duplicate_company_count += 1
      else
        company = Company.new(name: user.company, trading_name: user.company, website: user.website)
        if company.valid?
          if user.addresses.postal.any?
            postal_address = user.postal_address
            company.addresses.build(address_type: Address::POSTAL, 
                                     line_1: user.postal_address.line_1,
                                     line_2: user.postal_address.line_2,
                                     suburb: user.postal_address.suburb,
                                     state: user.postal_address.state,
                                     postcode: user.postal_address.postcode,
                                     country: user.postal_address.country)
            address_count += 1
          end
          company.save!
          company_count += 1
        end
      end
      user.representing_company_id = company.id
      user.save!
    end
    
    puts "Number of companies created: #{company_count}"
    puts "Number of companies reused: #{duplicate_company_count}"
    puts "Number of company addresses created: #{address_count}"
  end
end