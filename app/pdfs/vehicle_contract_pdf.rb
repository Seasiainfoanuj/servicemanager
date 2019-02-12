require 'prawn/table'

class VehicleContractPdf < Prawn::Document
  include ActionView::Helpers::SanitizeHelper

  def initialize(vehicle_contract, view)
    super(left_margin: 20, right_margin: 20, top_margin: 30, bottom_margin: 50, :page_size => "A4")
    font_size 9
    @presenter = VehicleContractPresenter.new(vehicle_contract)
    @contract = @presenter.vehicle_contract
    @quote = Quote.find(@contract.quote_id)
    @dealer = @quote.invoice_company
    @vehicle = @contract.vehicle
    @stock = @contract.allocated_stock
    @manager = @quote.manager
    @customer = @contract.customer
    @customer_company = @customer.representing_company
    @view = view
    build_contract_pdf_form
  end

  def build_contract_pdf_form
    header
    parties
    vehicle_description

    start_new_page

    options_and_accessories
    special_conditions
    price_and_terms

    start_new_page

    terms_and_conditions
    signatures
    page_footer
  end

  def header
    y_position = cursor
    pad_top(15) { text "CONTRACT OF SALE", size: 16, style: :bold, align: :left }
    pad_top(10) { text "for New Motor Vehicle", size: 16 }
    pad_top(10) { text "Contract reference: #{@contract.uid}", size: 14 }

    bounding_box([220, y_position], width: 170 ) do
      begin
        move_down 15
        fill_color '2176DE'
        text @contract.current_status.upcase, size: 16, style: :bold, align: :center
      rescue
        nil
      end
    end

    bounding_box([400, y_position], width: 160, height: 80) do
      begin
        move_down 15
        if @dealer.logo
          image @dealer.logo.path(:large), width: 160, align: :right
        end
      rescue
        nil
      end  
    end

    move_down 15
    stroke do
      self.line_width = 3
      horizontal_rule
    end
  end 

  def parties
    move_down 12
    section_heading("A - THE PARTIES")
    bus4x4_address = { line1: @dealer.name, 
                       line2: @dealer.address_line_1, 
                       line3: @presenter.dealer_suburb_line }
    y_position = cursor

    #  ---------- DEALER DETAILS -----------
    bounding_box([0, y_position], width: 120, height: 120) do
      text "DEALERS' NAME AND ADDRESS"
    end
    bounding_box([125, y_position], width: 140, height: 120) do
      text "(Here in referred to as 'The Dealer')", styles: [:italic]
      text bus4x4_address[:line1]
      text bus4x4_address[:line2], styles: [:normal]
      text bus4x4_address[:line3], styles: [:normal]
      move_down 10
      text "ph: #{@dealer.phone}"
      text "fax: #{@dealer.fax}"
    end

    seller_data = [["Sales Person", @presenter.manager_name], ["Order date", ""] ]
    dealer_data = [["Dealer ABN", @presenter.dealer.abn], ["Dealer Lic No.", BUS4X4_LICENCE_NUMBER] ]
    bounding_box([300, y_position], width: 230) do
      table_properties = { column_widths: [80, 150], 
                           cell_style: { border_color: '444444', border_width: 0.6} }
      table(seller_data, table_properties)
      move_down 10
      table(dealer_data, table_properties)
    end
    move_down 20

    stroke_horizontal_rule
    move_down 5
    y_position = cursor

    #  ---------- PURCHASER DETAILS -----------
    bounding_box([0, y_position], width: 120, height: 20) do
      text "PURCHASERS' NAME(s) AND ADDRESS(es)"
    end

    bounding_box([125, y_position], width: 140) do
      text "(Here in referred to as 'The Customer')", styles: [:italic]
      text @presenter.customer.name
      @presenter.customer_address_lines.each do |line|
        text line, styles: [:normal]
      end
      move_down 10
      text "ph: #{@presenter.customer.phone}"
      text "fax: #{@presenter.customer.fax}"
      move_down 5
    end
    y_position_section = cursor
    customer_data = [["Customer name", @presenter.customer.name],
                     ["Company name", @presenter.customer_company_name],
                     ["Customer ABN", @presenter.customer_abn]]

    bounding_box([300, y_position], width: 230, height: 100) do
      table_properties = { column_widths: [80, 150], 
                           cell_style: { border_color: '444444', border_width: 0.6} }
      table( customer_data, table_properties)
    end
    
    cursor = y_position_section
    move_down 5

    stroke_horizontal_rule
    move_down 5
    text "The Purchaser agrees to buy from the Dealer, and the Dealer agrees to sell " +
         "the Purchaser the motor vehicle and accessories described in Sections B and " +
         "C on the terms and conditions below and on the adjacent pages"
  end

  def vehicle_description
    move_down 30
    section_heading("B - DESCRIPTION OF THE MOTOR VEHICLE")

    if @presenter.vehicle.present?
      build_date = @presenter.vehicle_build_date
      vehicle_attributes = [["Make & model", @presenter.vehicle_model, "VIN number", @presenter.vehicle_vin_number],
                            ["Body Type", @presenter.vehicle_body_type, "Engine number", @presenter.vehicle_engine_number],
                            ["Colour", @presenter.vehicle_colour, "Registration number", @presenter.rego_number],
                            ["Transmission type", @presenter.vehicle_transmission, "Build date", @presenter.vehicle_build_date],
                            ["Engine type", @presenter.engine_type, "", ""]]
      bounding_box([0, cursor], width: bounds.width, height: 120) do
        self.line_width = 1
        table_properties = { column_widths: [110, 160, 110, 160], 
                             cell_style: { border_color: '444444', border_width: 0.6}}
        table(vehicle_attributes, table_properties)
      end
    else
      text 'VEHICLE DETAILS UNAVAILABLE'
    end
  end

  def options_and_accessories
    section_heading("C - OPTIONS AND ACCESSORIES SUPPLIED AND/OR FITTED")

    move_down 10
    data = [[ {:content => "Item Type", :background_color => 'E3E3E3'}, 
              {:content => "Description", :background_color => 'E3E3E3'}, 
              {:content => "Price $", :background_color => 'E3E3E3'} ]]

    current_name = ""
    @presenter.visible_items.each do |item|
      hide_name = (current_name == item[:quote_item_type])
      current_name = item[:quote_item_type]
      col_1 = hide_name ? "" : item[:quote_item_type].humanize.upcase
      if ["Vehicle Registration", "CTP Insurance", "Stamp duty"].exclude?(item[:item_name])
        heading = item[:item_name].upcase
        heading += " ( X #{item[:quantity]} )" if item[:quantity] > 1
        col_2 = "[ #{heading} ]\n #{item[:description]}"
      else
        col_2 = item[:description]
      end
      if item[:hidden]
        col_3 = "**package**"
      else
        col_3 = @view.number_to_currency((item[:unit_cost] * item[:quantity] / 100), precision: 2)
      end
      data << [ {:content => col_1, :background_color => 'E3E3E3'}, col_2, col_3]
    end

    @presenter.hidden_items.each do |item|
      col_1 = ""
      if ["Vehicle Registration", "CTP Insurance", "Stamp duty"].exclude?(item[:item_name])
        heading = item[:item_name].upcase
        heading += " ( X #{item[:quantity]} )" if item[:quantity] > 1
        col_2 = "[ #{heading} ]\n #{item[:description]}"
      else
        col_2 = item[:description]
      end
      if item[:hidden]
        col_3 = "**package**"
      else
        col_3 = @view.number_to_currency((item[:unit_cost] * item[:quantity] / 100), precision: 2)
      end
      data << [ {:content => col_1, :background_color => 'E3E3E3'}, col_2, col_3]
    end

    table(data, header: true, column_widths: [80, 390, 70], cell_style: { border_color: '444444', border_width: 0.8}) do
      # self.line_width = 2
      column(2).style align: :right;
    end
    data = [[ {:content => "", :background_color => 'E3E3E3'}, 
             "Total options & accessories (incl GST)", @presenter.extras_only_total ]]
    table(data, header: false, column_widths: [80, 390, 70], cell_style: {border_color: '444444', border_width: 0.8, font_style: :bold}) do
      column(2).style align: :right;
    end      
  end

  def special_conditions
    start_new_page
    section_heading("D - SPECIAL CONDITIONS")
    data = [[strip_tags(@contract.special_conditions)]]
    table(data, header: false, column_widths: [540])

    move_down 30
    bounding_box([0, cursor], width: bounds.width, height: 20) do
      text "ACCEPTANCE OF VEHICLES DETAILS, OPTIONS AND ACCESSORIES", size: 12
    end

    bounding_box([0, cursor], width: bounds.width, height: 80) do
      font_size 9
      stroke do
        self.line_width = 1
        fill_color 'E3E3E3'
        fill_rectangle [cursor-bounds.height,cursor], bounds.width - 14, 20
        fill_color '000000'
      end  
      signature_details = [["Date:", "Customer initials:", "Dealer representative:"], 
                           [" ", "", ""], 
                           [" ", @presenter.customer_name, @presenter.manager_name]]
      table_properties = { column_widths: [140, 160, 240], 
                           header: true,
                           cell_style: { border_color: '444444', border_width: 0.5} }
      table(signature_details, table_properties) do
        row(1).style height: 30
      end
    end
  end

  def price_and_terms
    move_down 30
    section_heading("E - PRICE AND TERMS OF SETTLEMENT")

    # data = [[ {:content => "Item Type", :background_color => 'E3E3E3'}, 
    #           {:content => "Description", :background_color => 'E3E3E3'}, 
    #           {:content => "Price $", :background_color => 'E3E3E3'} ]]

    # table(settlement_details, column_widths: [155, 120, 155, 120]) do
    #   cells.padding = 5
    #   cells.borders = []
    #   column(1).style :align => :center
    #   column(3).style :align => :center
    # end

    y_position = cursor
    data = [["PRICE OF THE MOTOR VEHICLE", "$", "TERMS OF SETTLEMENT", "$" ],
            ["Sale price of motor vehicle", @presenter.sale_price_vehicle_alone, "", ""], 
            ["Accessories, add-ons and other items as per Section C", @presenter.extras_only_total, "", ""],
            ["Packaged items as per Section C", @presenter.packaged_items_total, "", ""],
            ["PURCHASE PRICE", @presenter.sale_price_before_registration, "", ""],
            ["GST", @presenter.total_gst, "", ""],
            ["FEES:", "", "", ""], 
            ["Registration", @presenter.registration_total, "", ""],
            ["Stamp Duty", @presenter.stamp_duty_total, "", ""],
            ["CTP Insurance", @presenter.ctp_insurance_total, "", ""],
            ["CONTRACT AMOUNT (Purchase Price + GST + Fees", @presenter.total_amount_payable, "", ""],
            ["minus: Deposit amount paid", @presenter.deposit_received, "", ""],  
            ["BALANCE DUE (Contract Amount - Deposit Paid", @presenter.balance_due, "", ""],
            ]

    bounding_box([0, y_position], width: 554, height: 340) do
      table(data, header: true, column_widths: [187, 90, 187, 90], cell_style: { border_color: '6A6A6A', border_width: 0.6}) do
        column(0).style :align => :left
        column(1).style :align => :right
        column(2).style :align => :left 
        column(3).style :align => :right
        row(0).style :background_color => 'E3E3E3'
        row(4).style :font_style => :bold
        row(7).style :padding_left => 20
        row(8).style :padding_left => 20
        row(9).style :padding_left => 20
        row(10).style :font_style => :bold
        row(12).style :font_style => :bold
      end

      data = [["Variations to the contract are subject to 20% surcharge on costs items"]]
      table(data, header: false, column_widths: [554], cell_style: { border_color: '6A6A6A', border_width: 0.6}) do
        row(0).style :background_color => 'E3E3E3'
      end
    end
  end

  def  terms_and_conditions
    section_heading("F - TERMS AND CONDITIONS")
  end

  def signatures
    section_heading("G - SIGNATURES")
    font_size 12
    text "IMPORTANT !!"
    font_size 9
    text "READ THIS DOCUMENT CAREFULLY BEFORE YOU SIGN", :align => :center
    move_down 3
    font_size 12
    text "THIS DOCUMENT BECOMES A LEGALLY BINDING CONTRACT", :align => :center
    move_down 3
    font_size 9
    text "UPON ACCEPTANCE BY THE DEALER", :align => :center
    move_down 20
    y_position = cursor
    font_size 9
    bounding_box([0, y_position], width: 220, height: 80) do
      text "Customer 1 Signature _______________________"
      move_down 10
      text "Date Signed _______________________________"
    end

    bounding_box([240, y_position], width: 240, height: 80) do
      text "Customer 2 Signature ____________________________"
      move_down 10
      text "Acceptance on behalf of dealer _____________________"
    end

    font_size 10
    text "- - - - - - - END OF CONTRACT - - - - - - -", :align => :center
  end

  def section_heading(title)
    font_size 10
    bounding_box([0, cursor], width: bounds.width, height: 20) do
      stroke do
        self.line_width = 1
        fill_color 'B3E6FF'
        fill_and_stroke_rounded_rectangle [cursor-bounds.height,cursor], bounds.width, bounds.height, 5
        fill_color '000000'
      end  
      pad(5) { text title, align: :center }
    end
    move_down 10
    font_size 9
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