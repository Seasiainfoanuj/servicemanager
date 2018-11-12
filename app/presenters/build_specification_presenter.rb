class BuildSpecificationPresenter

  attr_reader :build_specification

  def initialize(build_specification)
    @build_specification = build_specification
    @build = @build_specification.build
    @invoice_company = @build.invoice_company
    @vehicle = @build.vehicle
  end

  def passenger_door(options = {format: :html})
    if options[:format] == :html
      @build_specification.swing_type_display
    else
      [[@build_specification.swing_type_display]]
    end
  end

  def paint(options = {format: :html})
    if options[:format] == :html
      @build_specification.paint.html_safe
    else
      [[ActionController::Base.helpers.strip_tags(@build_specification.paint)]]
    end
  end

  def heating(options = {format: :html})
    if options[:format] == :html
      @build_specification.heating_source_display
    else
      [[@build_specification.heating_source_display]]
    end
  end

  def no_of_seats(options = {format: :html})
    if options[:format] == :html
      @build_specification.total_seat_count
    else
      [[@build_specification.total_seat_count]]
    end
  end

  def seating(options = {format: :html})
    if options[:format] == :html
      @build_specification.seating_type_display
    else
      [[@build_specification.seating_type_display]]
    end
  end

  def other_seating(options = {format: :html})
    if options[:format] == :html
      @build_specification.other_seating.html_safe
    else
      [[ActionController::Base.helpers.strip_tags(@build_specification.other_seating)]]
    end
  end

  def school_bus_signs(options = {format: :html})
    if options[:format] == :html
      @build_specification.state_sign_display
    else
      [[@build_specification.state_sign_display]]
    end
  end

  def surveillance_system(options = {format: :html})
    if options[:format] == :html
      @build_specification.surveillance_system.html_safe
    else
      [[ActionController::Base.helpers.strip_tags(@build_specification.surveillance_system)]]
    end
  end

  def lift_up_wheel_arches(options = {format: :html})
    reply = @build_specification.lift_up_wheel_arches ? 'YES - On all airbag models' : 'NO'
    options[:format] == :html ? reply : [[reply]]
  end

  def other_comments(options = {format: :html})
    if options[:format] == :html
      @build_specification.comments.html_safe
    else
      [[ActionController::Base.helpers.strip_tags(@build_specification.comments)]]
    end
  end

  def vehicle_model
    @vehicle.model.name
  end

  def vehicle_vin
    @vehicle.vin_number
  end

  def build_number
    @build.number
  end

  def internal_company_logo
    if @invoice_company.logo.present?
      @invoice_company.logo.path(:large)
    else
      "/images/missing.png"
    end
  end

  def doors
    lines = []
    I18n.t("doors", scope: [:build_specifications, :complete]).each_with_index.map do |line|
      lines << [line[1]]
    end
    lines
  end

  def windows
    lines = []
    I18n.t("windows", scope: [:build_specifications, :complete]).each_with_index.map do |line|
      lines << [line[1]]
    end
    lines
  end

  def roof_hatches
    [[I18n.t("roof_hatches", scope: [:build_specifications, :complete])]]
  end

  def bumper_bars
    [[I18n.t("bumper_bars", scope: [:build_specifications, :complete])]]
  end

  def mirrors
    lines = []
    I18n.t("windows", scope: [:build_specifications, :complete]).each_with_index.map do |line|
      lines << [line[1]]
    end
    lines
  end

  def stepwell
    [[I18n.t("stepwell", scope: [:build_specifications, :complete])]]
  end

  def floor
    [[I18n.t("floor", scope: [:build_specifications, :complete])]]
  end

  def floor_covering
    [[I18n.t("floor_covering", scope: [:build_specifications, :complete])]]
  end

  def interior_panelling
    lines = []
    I18n.t("interior_panelling", scope: [:build_specifications, :complete]).each_with_index.map do |line|
      lines << [line[1]]
    end
    lines
  end

  def airconditioning
    [[I18n.t("airconditioning", scope: [:build_specifications, :complete])]]
  end

  def exterior_lights
    lines = []
    I18n.t("exterior_lights", scope: [:build_specifications, :complete]).each_with_index.map do |line|
      lines << [line[1]]
    end
    lines
  end

  def speakers
    [[I18n.t("speakers", scope: [:build_specifications, :complete])]]
  end

  def stickers
    [[I18n.t("stickers", scope: [:build_specifications, :complete])]]
  end

  def modesty_panel
    [[I18n.t("modesty_panel", scope: [:build_specifications, :complete])]]
  end

  def reverse_camera
    lines = []
    I18n.t("reverse_camera", scope: [:build_specifications, :complete]).each_with_index.map do |line|
      lines << [line[1]]
    end
    lines
  end

  def accessories
    [[I18n.t("accessories", scope: [:build_specifications, :complete])]]
  end

  def storage
    lines = []
    I18n.t("storage", scope: [:build_specifications, :complete]).each_with_index.map do |line|
      lines << [line[1]]
    end
    lines
  end

end