namespace :cleanup_addresses do

  desc "Assign standard States to australian addresses"
  task "apply_standard_names" => :environment do
    addr_count = 0
    invalid_addr_count = 0
    Address.all.each do |addr|
      if addr.country.present? 
        if ['au', 'aust', 'aust.', 'australia'].include? addr.country.downcase.strip
          addr.country = 'Australia'
        end
      else
        addr.country = 'Australia'
      end
      case addr.state.downcase.strip
      when 'qld', 'queensland'
        addr.state = 'QLD'
      when 'act'
        addr.state = 'ACT'
      when 'nt', 'northern territory'
        addr.state = 'NT'
      when 'sa', 'south australia'
        addr.state = 'SA'
      when 'vic', 'victoria'
        addr.state = 'VIC'
      when 'tas', 'tasmania'
        addr.state = 'TAS'
      when 'wa', 'western australia'
        addr.state = 'WA'
      when 'nsw', 'new south wales'
        addr.state = 'NSW'
      end
      addr.postcode = addr.postcode.strip
      addr.suburb = addr.suburb.strip.titleize
      if addr.valid?
        addr.save!
        addr_count += 1
      else
        invalid_addr_count += 1
        addr.country = 'Austria'
        addr.save!
      end
    end
    puts "Total number of addresses modified: #{addr_count}"
  end

  desc "Remove addresses with insufficient details"
  task "remove_empty_addresses" => :environment do
    foreign_country_count = 0
    deleted_addresses_count = 0
    foreign_country_ids = []
    Address.all.each do |addr|
      if addr.line_1.blank? && addr.line_2.blank?
        deleted_addresses_count += 1
        addr.delete
      elsif addr.suburb.blank? && addr.postcode.blank?
        deleted_addresses_count += 1
        addr.delete
      elsif addr.country != 'Australia'
        foreign_country_count += 1
        foreign_country_ids << addr.id
      end
    end
    puts "Address deleted: #{deleted_addresses_count}"
    puts "Non-Australian addresses remaining: #{foreign_country_count}"
    puts "Non-Australian address ids: #{foreign_country_ids.inspect}"
  end
  
end