module CompaniesHelper

  def options_for_users_with_company
    contacts = []
    User.includes(:representing_company).each do |contact| 
      next if contact.employee?
      if contact.representing_company
        contacts << ["#{contact.first_name} #{contact.last_name} (#{contact.email}) - **#{contact.representing_company.name}**", contact.id]
      else
        contacts <<["#{contact.first_name} #{contact.last_name} (#{contact.email})", contact.id]
      end
    end
    contacts
  end

  def contact_authorisation_details(company, contact)
    if contact == company.default_contact
      'Authorised'
    else
      'Read only'
    end
  end

end