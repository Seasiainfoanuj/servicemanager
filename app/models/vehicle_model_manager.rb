class VehicleModelManager

  def self.new_vehicle_model_created(vehicle_model)
    self.create_default_fees(vehicle_model)
  end

  def self.create_default_fees(vehicle_model)
    FeeType.includes(:standard_fee).each do |feetype|
      amount = feetype.standard_fee ? feetype.standard_fee.fee_cents : 0
      vehicle_model.fees.build(fee_type: feetype, fee_cents: amount)
    end
    vehicle_model.save!
  end

end