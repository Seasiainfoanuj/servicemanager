require 'prawn/table'

class BuildSpecificationPdf < Prawn::Document

  def initialize(spec_presenter, view)
    super(left_margin: 20, right_margin: 20, top_margin: 30, bottom_margin: 40, :page_size => "A4")
    font_size 9
    @spec_presenter = spec_presenter
    @view = view
    spec_header
    vehicle_header
    standard_features
    custom_features
    page_footer
  end

  def spec_header
    y_position = cursor
    pad_top(15) { text "Build Specification Sheet", size: 18, style: :bold, align: :left }
    pad_top(10) { text "for #{@spec_presenter.build_number}", size: 16 }
    move_down 10
    stroke do
      self.line_width = 3
      horizontal_rule
    end
    bounding_box([340, y_position], width: 210, height: 90) do
      begin
        move_down 15
        image @spec_presenter.internal_company_logo, width: 210, align: :right 
      rescue
        nil
      end  
    end
  end

  def vehicle_header
    vehicle_table = [["Vehicle details", "Model: #{@spec_presenter.vehicle_model}", "VIN number: #{@spec_presenter.vehicle_vin}"]]
    bounding_box([0, cursor], width: bounds.width, height: 50) do
      self.line_width = 1
      table(vehicle_table, column_widths:[100, 220, 220]) do
        style(row(0).column(0), background_color: 'E3E3E3')
      end
    end
  end

  def standard_features
    label_style = { borders: [], text_color: '0067E8', size: 11 }
    data_style = { column_widths: [400], cell_style: { :borders => []} }

    pad_top(15) { text "Standard Features", size: 18, style: :bold, align: :left, color: 'FF0202' }

    features = %w( doors windows roof_hatches bumper_bars mirrors stepwell floor floor_covering
                   interior_panelling airconditioning exterior_lights speakers stickers
                   modesty_panel reverse_camera accessories storage)

    features.each do |feature|
      label_data = make_table([[feature.humanize.upcase]], cell_style: label_style)
      doors_data = make_table(@spec_presenter.send(feature.to_sym), data_style )
      table([ [label_data, doors_data]], :column_widths => [140, 400])
    end
  end

  def custom_features
    label_style = { borders: [], text_color: '0067E8', size: 11 }
    data_style = { column_widths: [390], cell_style: { :borders => []} }

    pad_top(15) { text "Customised Features", size: 18, style: :bold, align: :left, color: 'FF0202' }

    features = %w(passenger_door paint heating no_of_seats seating other_seating 
                  school_bus_signs surveillance_system lift_up_wheel_arches other_comments)

    features.each do |feature|
      label_data = make_table([[feature.humanize.upcase]], cell_style: label_style)
      doors_data = make_table(@spec_presenter.send(feature.to_sym, {format: :pdf}), data_style )
      table([ [label_data, doors_data]], :column_widths => [150, 390])
    end

  end

  def page_footer
    page_count.times do |i|
      bounding_box([bounds.left, bounds.bottom], :width => bounds.width, :height => 30) {
        go_to_page i+1
        move_down 5 # move below the document margin
        text "page #{i+1} of #{page_count}", :align => :center # write the page number and the total page count
      }
    end
  end
end