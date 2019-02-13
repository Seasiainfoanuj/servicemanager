# VehicleContractManager is responsible to extend VehicleContract Controller
# actions by taking care of process-related updates which are not directly
# related to Vehicle Contract records. This is an attempt to centralise
# business process intelligence in one place. 
class VehicleContractManager

  def self.may_select_allocated_stock?(vehicle_contract, current_user)
    current_user.admin? && !vehicle_contract.persisted?
  end

  def self.can_replace_allocated_stock_with_vehicle?(allocated_stock_id)
    allocated_stock = Stock.find(allocated_stock_id)
    return true unless allocated_stock.vin_number.present?
    vehicle = Vehicle.find_by(vin_number: allocated_stock.vin_number)
    vehicle.present? ? false : true 
  end

  def self.finalise_new_contract(vehicle_contract, current_user)
    contract = vehicle_contract
    self.replace_allocated_stock_with_vehicle(contract)
    contract_status = VehicleContractStatus.create!(vehicle_contract: contract,
      changed_by: current_user, 
      name: VehicleContractStatusManager.status_after_action(:create)
    )
    contract.create_activity :create, owner: current_user
  end

  def self.complete_verification(vehicle_contract, current_user)
    contract = vehicle_contract
    new_status = VehicleContractStatusManager.status_after_action(:verify_customer_info)
    contract.current_status = new_status
    contract.save!
    contract_status = VehicleContractStatus.create!(vehicle_contract: contract,
      changed_by: current_user, 
      name: new_status
    )
    contract.create_activity :verify_customer_info, owner: current_user
  end

  def self.prepare_contract_for_sending(vehicle_contract, current_user)
    contract = vehicle_contract
    new_status = VehicleContractStatusManager.status_after_action(:send_contract)
    contract.current_status = new_status
    contract.save!
    VehicleContractStatus.create!(vehicle_contract: contract,
      changed_by: current_user, 
      name: new_status
    )
    contract.create_activity :send_contract, recipient: contract.customer, owner: current_user
  end

  def self.complete_upload(vehicle_contract, current_user)
    contract = vehicle_contract
    new_status = VehicleContractStatusManager.status_after_action(:send_contract)
    unless contract.current_status == new_status
      contract.current_status = new_status
      contract.save!
    end      
    vehicle_contract.create_activity :upload_contract, owner: current_user
  end

  def self.complete_acceptance(vehicle_contract, options = {})
    current_user = options[:current_user]
    client_ip = options[:ip_address]
    contract = vehicle_contract
    new_status = VehicleContractStatusManager.status_after_action(:accept)
    unless contract.current_status == new_status
      contract.current_status = new_status
      contract.save!
    end      
    VehicleContractStatus.create!(vehicle_contract: contract,
      changed_by: current_user, 
      name: new_status,
      signed_at_location_ip: client_ip
    )
    vehicle_contract.create_activity :accept_notice, owner: current_user
  end

  def self.replace_allocated_stock_with_vehicle(contract)
    allocated_stock = contract.allocated_stock
    return unless allocated_stock
    if allocated_stock.transmission.present? && Vehicle::TRANSMISSION_TYPES.include?(allocated_stock.transmission.titleize)
      transmission = allocated_stock.transmission.titleize
    else
      transmission = 'Manual'
    end
    vehicle = Vehicle.create!(vehicle_model_id: allocated_stock.vehicle_model_id,
                   supplier_id: allocated_stock.supplier_id,
                   vin_number: allocated_stock.vin_number,
                   engine_number: allocated_stock.engine_number,
                   colour: allocated_stock.colour,
                   transmission: transmission,
                   status: 'on_offer'
      )
    allocated_stock.destroy
    new_contract = contract
    new_contract.vehicle = vehicle
    new_contract.allocated_stock_id = nil
    new_contract.save!
  end
end