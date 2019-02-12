namespace :hire_quotes do

  desc "Assign authorised contact to hire quote"
  task "assign_authorised_contacts" => :environment do
    HireQuote.all.each do |hq|
      if hq.customer.person?
        hq.authorised_contact_id = hq.customer.user.id
      else
        hq.authorised_contact_id = hq.customer.company.contacts.first.id
      end
      hq.save
    end
  end
end