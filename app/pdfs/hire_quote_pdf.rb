require 'prawn/table'

class HireQuotePdf < Prawn::Document
  include ActionView::Helpers::SanitizeHelper

  def initialize(hire_quote, view)
    super(left_margin: 20, right_margin: 20, top_margin: 30, bottom_margin: 50, :page_size => "A4")
    @hire_quote = hire_quote
    @presenter = HireQuotePresenter.new(hire_quote, view)
    @customer_contact = hire_quote.authorised_contact
    @dealer = @hire_quote.quoting_company
    @view = view
    build_hire_quote_pdf_form
  end

  def build_hire_quote_pdf_form
    font_size 10
    print_cover_letter

    start_new_page
    font_size 9

    print_header( { include_status: true} )
    print_parties
    print_quote_lines
    print_pictures
    page_footer
  end

  def print_parties
    dealer_address = ["From:"]
    dealer_address << @presenter.quoting_company_name
    dealer_address << @presenter.quoting_company_address( {usage: :pdf} )
    dealer_address.flatten!

    customer_address = ["To:"]
    customer_address << @presenter.customer_email
    customer_address << @presenter.preferred_customer_address
    y_position = cursor
    font_size 10

    #  ---------- DEALER DETAILS -----------
    bounding_box([10, y_position], width: 180, height: 100) do
      dealer_address.each { |line| text line }
    end

    #  ---------- CUSTOMER DETAILS -----------
    bounding_box([210, y_position], width: 220, height: 100) do
      customer_address.each { |line| text line }
    end

    #  ---------- QUOTE DATE -----------
    status_date_label = case @hire_quote.status
    when "sent"
      "Date sent:"
    when "accepted"
      "Date accepted:"
    else
      @hire_quote.status
    end

    bounding_box([420, y_position], width: 100, height: 100) do
      text status_date_label
      text @view.display_date(@hire_quote.status_date)
    end
  end

  def print_quote_lines
    y_position = cursor
    font_size 9
    data = [["Hire Start Date", "Hire End Date", "Hire Product", "Mobilisation", "Rate", "Frequency", "GST", "Line Total" ]]

    @hire_quote.vehicles.each do |vehicle|
      start_date = @view.display_date(vehicle.start_date, {format: :short})
      end_date = @view.display_date(vehicle.end_date, {format: :short})
      vehicle_model = vehicle.name
      mobilisation = vehicle.mobilisation_requirements
      rate = @view.number_to_currency((vehicle.daily_rate_cents / 100), precision: 2, separator: '.', unit: '$')
      gst_cents = @presenter.gst_percentage * vehicle.daily_rate_cents
      gst = @view.number_to_currency( gst_cents / 100, precision: 2, separator: '.', unit: '')
      line_total = @view.number_to_currency( (vehicle.daily_rate_cents + gst_cents) / 100, precision: 2, separator: '.', unit: '$')
      data << [start_date, end_date, vehicle_model, mobilisation, rate, 'per day', gst, line_total]

      vehicle.addons.each do |addon|
        addon_name = "#{addon.hire_addon.addon_type} - #{addon.hire_addon.hire_model_name}"
        rate = @view.number_to_currency((addon.hire_price_cents / 100), precision: 2, separator: '.', unit: '$')
        frequency = addon.hire_addon.billing_frequency
        gst_cents = @presenter.gst_percentage * addon.hire_price_cents
        gst = @view.number_to_currency( gst_cents / 100, precision: 2, separator: '.', unit: '')
        line_total = @view.number_to_currency( (addon.hire_price_cents + gst_cents) / 100, precision: 2, separator: '.', unit: '$')
        data << ['', '', addon_name, '', rate, frequency, gst, line_total]
      end
    end

    bounding_box([0, y_position], width: 554) do
      table(data, header: true, column_widths: [57, 57, 142, 72, 56, 58, 56, 56], cell_style: { border_color: '7F7F7F', border_width: 0.6, font: 'Helvetica'}) do
        column(0).style :align => :left
        column(1).style :align => :left
        column(2).style :align => :left 
        column(3).style :align => :left
        column(4).style :align => :right
        column(5).style :align => :right
        column(6).style :align => :right
        column(7).style :align => :right
        row(0).style :background_color => 'E3E3E3'
      end
    end
  end

  def print_pictures
    move_down 20
    font_size 12
    @hire_quote.vehicles.each_with_index do |vehicle, inx|
      photo = vehicle.vehicle_model.images.photos.first
      y_pos = cursor
      if inx.even?
        x_pos = 10
      else
        x_pos = 280
      end
      indent(x_pos) do
        text_box vehicle.vehicle_model.name, at: [0, y_pos], width: 180, height: 15
        image photo.image.path(:medium), width: 240, at: [0, cursor - 15]
      end
      if inx.odd?
        if y_pos < 320
          start_new_page
        else
          move_down 170
        end
      end
    end
  end

  def print_header( options = {})
    y_position = cursor
    bounding_box([10, y_position], width: 160, height: 40) do
      begin
        if @dealer.logo
          image @dealer.logo.path(:large), width: 160, align: :left
        end
      rescue
        nil
      end  
    end

    if options[:include_status]
      formatted_text_box [ { text: @hire_quote.status.titleize, color: "FF3300", styles: [:bold] } ], at: [200, y_position], width: 180, align: :center, size: 16
    end
    text_box "Ref: #{@hire_quote.reference}", :at => [420, y_position], :width => 120, :align => :right, size: 14, :styles => [:bold]
  end

  def print_cover_letter
    print_header
    print_dealer_on_cover_page
    print_customer_on_cover_page
    print_product_title
    move_down 40
    print_letter_content if @hire_quote.cover_letter
  end

  def print_product_title
    product_names = @hire_quote.vehicles.map { |veh| veh.vehicle_model.full_name }
    unique_names = product_names.sort.uniq
    titles = []
    unique_names.each do |name|
      count = product_names.count { |n| n == name }
      if count == 1
        titles << name
      else
        titles << "#{name} (X #{count})"
      end
    end

    y_position = cursor - 10
    text_box titles.join(", "), :at => [10, y_position], :width => 500, :align => :center, size: 14, :styles => [:bold]
  end

  def print_letter_content
    text_box @hire_quote.cover_letter.content, :at => [10, cursor], :width => 520, :align => :left, size: 10, :styles => [:normal]
  end

  def print_dealer_on_cover_page
    y_position = cursor
    dealer_address = []
    dealer_address << @presenter.quoting_company_name
    dealer_address << @presenter.quoting_company_address( {usage: :pdf, phone: true, fax: true} )
    dealer_address.flatten!
    bounding_box([420, y_position], width: 120, height: 100) do
      dealer_address.each_with_index do |line, inx| 
        move_down 8 if line =~ /Phone/
        text line 
      end
    end
  end

  def print_customer_on_cover_page
    customer_address = []
    customer_address << @presenter.customer_name
    customer_address << @presenter.customer_email
    customer_address << @presenter.preferred_customer_address
    y_position = cursor + 40
    font_size 10

    #  ---------- CUSTOMER DETAILS -----------
    bounding_box([10, y_position], width: 220, height: 80) do
      customer_address.each { |line| text line }
    end

    y_position = cursor
    bounding_box([10, y_position], width: 220, height: 30) do
      text "Phone: #{@customer_contact.phone}"
      text "Mobile: #{@customer_contact.mobile}"
    end
  end

  def page_footer
    page_count.times do |i|
      bounding_box([bounds.left, bounds.bottom], :width => bounds.width, :height => 30) {
        # for each page, count the page number and write it
        go_to_page i+1
        move_down 5 # move below the document margin
        text "page #{i+1} of #{page_count}", :align => :center # write the page number and the total page count
      }
    end
  end

end