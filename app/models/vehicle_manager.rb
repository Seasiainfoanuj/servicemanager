class VehicleManager

  def self.finalise_new_vehicle(vehicle, current_user)
    new_vehicle = vehicle
    new_vehicle.supplier_id = current_user.id if current_user.has_role? :supplier
    new_vehicle.save!
    new_vehicle.create_activity :create, owner: current_user
  end

  def self.finalise_vehicle_update(vehicle, current_user)
    vehicle.create_activity :update, owner: current_user
  end
end