class HireQuotePresenter < BasePresenter
  delegate :link_to, to: :@view

  attr_reader :hire_quote, :quoting_company, :preferred_customer_address

  def initialize(model, view)
    super
    @update_vehicles = nil
    @hire_quote = model
    @quoting_company ||= quoting_company
    @customer_company ||= customer_company
    @preferred_customer_address ||= preferred_customer_address
  end

  def options_for_customers
    Client.includes(:company, user: :representing_company).collect do |client|
      if client.person?
        if client.user.representing_company
          ["#{client.user.representing_company.name} - #{client.user.first_name} #{client.user.last_name} - #{client.user.email}", client.id]
        else
          ["#{client.user.first_name} #{client.user.last_name} - #{client.user.email}", client.id]
        end
      else
        ["COMPANY: #{client.company}", client.id]
      end  
    end
  end

  def options_for_company_contacts
    if customer.company?
      customer.company.contacts.collect do |user|
        ["#{user.representing_company.name} - #{user.first_name} #{user.last_name} - #{user.email}", user.id]
      end
    end
  end

  def customer_company
    return unless customer
    if customer.company?
      customer.company
    else
      customer.user.representing_company
    end
  end

  def customer_company_name
    @customer_company.name if @customer_company
  end

  def selected_customer
    customer.id if customer
  end

  def selected_authorised_contact
    authorised_contact.id if authorised_contact
  end

  def options_for_managers
    Client.manager.collect { |client| ["#{client.user.first_name} #{client.user.last_name} - #{client.user.email}", client.id] }
  end

  def selected_manager
    manager.id if manager
  end

  def heading
    "Hire Quote #{h.hire_quote_reference_label(@hire_quote)} for #{customer_name}".html_safe
  end

  def customer_name( options = {})
    customer.person? ? person_name(options) : customer_company.name
  end

  def person_name(options)
    "#{customer.user.first_name} #{customer.user.last_name} #{('(' + customer.user.email + ')') if options[:email]}"
  end

  def manager_name
    manager.name if manager
  end  

  def client_details_link
    customer.person? ? person_details_link : company_details_link
  end

  def authorised_contact_link
    h.link_to('<i class="icon-search"></i>'.html_safe, authorised_contact)
  end

  def person_details_link
    h.link_to('<i class="icon-search"></i>'.html_safe, customer.user)
  end

  def company_details_link
    h.link_to('<i class="icon-search"></i>'.html_safe, customer.company)
  end

  def status_details
    status_display = "<b>#{status.titleize}</b>&nbsp;&nbsp;"
    "#{status_display}  (last changed on #{h.display_date(status_date)})".html_safe
  end

  def last_viewed_display
    last_viewed ? h.display_time(last_viewed) : 'Not viewed yet' 
  end

  def show_status_label?
    h.current_user.admin? || status == "changes requested" || status == "accepted"
  end

  def company_logo(size)
    @quoting_company.logo.url(size)
  end

  def quoting_company_name
    BUS4X4_HIRE_COMPANY_NAME
  end

  def quoting_company
    InvoiceCompany.find_by(slug: 'bus_hire')
  end

  def customer_name_and_email
    "#{authorised_contact.name} (#{authorised_contact.email})"
  end

  def customer_email
    authorised_contact.email if authorised_contact
  end

  def quoting_company_address(options = {})
    lines = []
    lines << @quoting_company.address_line_1
    lines << @quoting_company.address_line_2 if @quoting_company.address_line_2.present?
    lines << "#{@quoting_company.suburb}, #{@quoting_company.state} #{@quoting_company.postcode}"
    lines << @quoting_company.country
    lines << "Phone: #{@quoting_company.phone}" if options[:phone] and @quoting_company.phone
    lines << "Fax: #{@quoting_company.fax}" if options[:fax] and @quoting_company.fax
    if options[:usage] == :html
      lines.join('<br>').html_safe
    elsif options[:usage] == :pdf
      lines
    else
      lines
    end
  end

  def quoting_company_address_formatted(options = {})
    lines = quoting_company_address(options)
    lines.join('<br>').html_safe
  end

  def hire_quote_cover_letter_address
    address = authorised_contact.physical_address || authorised_contact.postal_address
    return unless address
    lines = []
    lines << address.line_1
    lines << address.line_2 if address.line_2.present?
    lines << "#{address.suburb}, #{address.state} #{address.postcode}"
    lines << address.country
    lines.join('</br>').html_safe
  end

  def customer_contact_details(options = {})
    contact_lines = []
    contact_lines << "Email: #{authorised_contact.email}" if options[:email]
    contact_lines << "Phone: #{authorised_contact.phone}" if options[:phone] and authorised_contact.phone.present?
    contact_lines << "Mobile: #{authorised_contact.mobile}" if options[:mobile] and authorised_contact.mobile.present?
    contact_lines << "Website: #{authorised_contact.website}" if options[:website] and authorised_contact.website.present?
    return "" if contact_lines.none?
    contact_lines.join('</br>').html_safe
  end

  def preferred_customer_address
    return nil unless authorised_contact
    user = authorised_contact
    address = authorised_contact.preferred_address( {usage: :hire_quote} )
    return if address.nil?
    lines = []
    lines << address.line_1
    lines << address.line_2 if address.line_2.present?
    lines << "#{address.suburb} #{address.state} #{address.postcode}"
    lines << address.country
    lines.join("\n")
  end

  def quoting_company_acn
    @quoting_company.acn
  end

  def quoting_company_abn
    @quoting_company.abn
  end

  def quoting_company_phone
    @quoting_company.phone
  end

  def quoting_company_fax
    @quoting_company.fax
  end

  def quoting_company_cover_letter_address
    address_lines =[]
    address_lines << "#{@quoting_company.address_line_1}<br>"
    address_lines << "#{@quoting_company.address_line_2}<br>" if @quoting_company.address_line_2.present?
    address_lines << "#{@quoting_company.suburb}, #{@quoting_company.state}, #{@quoting_company.postcode}, #{@quoting_company.country}"
    address_lines
  end

  def quoted_date
    if quoted_date.present?
      h.display_date(quoted_date)
    else
      "Quote not yet sent"
    end
  end

  def send_resend_text
    status == "sent" ? "Resend" : "Send"
  end

  def request_changes_text
    status == "changes requested" ? "Request more changes" : "Request changes"
  end

  def gst_percentage
    Tax.find_by(name: "GST").rate.to_f
  end

end
