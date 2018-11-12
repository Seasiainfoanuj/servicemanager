class VehiclePresenter < BasePresenter

  def initialize(model, view)
    super
    @supplier = model.supplier
    @owner = model.owner
  end

  def makes_and_models
    all_models = VehicleModel.includes(:make)
    all_models.collect { |model| ["#{model.make.name} #{model.name}", model.id ] }
  end

  def transmission_types
    Vehicle::TRANSMISSION_TYPES
  end

  def options_for_statuses
    Vehicle::STATUSES.collect { |status| [status.humanize.titleize, status]}
  end

  def selected_model
    model.present? ? vehicle_model_id : ""
  end

  def options_for_suppliers
    suppliers = User.supplier.includes(:representing_company)
    suppliers.collect do |user| 
      if user.representing_company
        ["#{user.representing_company.name} - #{user.first_name} #{user.last_name} - #{user.email}", user.id]
      else
        ["#{user.first_name} #{user.last_name} - #{user.email}", user.id]
      end
    end
  end

  def selected_supplier
    @supplier.present? ? supplier_id : ""
  end

  def options_for_owners
    owners = User.all.includes(:representing_company)
    owners.collect do |user| 
      if user.representing_company
        ["#{user.representing_company.name} - #{user.first_name} #{user.last_name} - #{user.email}", user.id]
      else
        ["#{user.first_name} #{user.last_name} - #{user.email}", user.id]
      end
    end
  end

  def selected_owner
    @owner.present? ? @owner.id : ""
  end

  def daily_rate
    return 0 unless hire_details
    h.number_with_precision(hire_details.daily_rate, :precision => 2)
  end

  def excess_km_rate
    return 0 unless hire_details
    h.number_with_precision(hire_details.excess_km_rate, :precision => 2)
  end

end
