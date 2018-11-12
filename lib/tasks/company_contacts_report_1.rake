namespace :companies do
  desc "Report on the contacts of companies"
  task :company_contacts_report_1 => :environment do
    Company.all.each do |cpy|
      if cpy.contacts.empty?
        puts "Company with no contacts: #{cpy.id} #{cpy.name}"
      end
      if cpy.contacts.count > 1
        puts "\nCompany with multiple contacts: #{cpy.id} #{cpy.name}"
        cpy.contacts.each do |user|
          user_roles = user.roles.map { |role| role.to_s.humanize }.flatten.join(', ')
          puts "Contact #{user.id} #{user_roles}"
        end
      end  
    end
  end
end  