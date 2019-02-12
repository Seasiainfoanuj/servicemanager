class HireVehicle < ActiveRecord::Base

  belongs_to :vehicle

  def make
    make = VehicleModel.find(vehicle.vehicle_model_id).make if vehicle && vehicle.vehicle_model_id.present?
  end

  def name
    if vehicle.present? && vehicle.vehicle_model_id.present?
      model = VehicleModel.find(vehicle.vehicle_model_id)
      make = model.make
      # year = model.year
      "#{make.name} #{model.name}"
    else
      "" #return empty string
    end
  end

  def ref_name
    if vehicle.present?
      vehicle.ref_name
    else
      "" #return empty string
    end
  end

end
