class VehicleContractMailer < ActionMailer::Base

  default from: "info@bus4x4.com.au"

  def vehicle_contract_email(customer_id, sent_by_id, vehicle_contract_id, message)
    begin
      @customer = User.find(customer_id)
      @sent_by  = User.find(sent_by_id)
      @vehicle_contract = VehicleContract.find(vehicle_contract_id)
      @quote = @vehicle_contract.quote
      @message = message
      mail to: @customer.email, 
           subject: "[#{@quote.invoice_company.name}] Vehicle Purchase Contract Number #{@vehicle_contract.uid}", 
           from: @sent_by.email
      rescue  => e       
      @error= e.class
      @details = ['An error occurred in VehicleContractMailer#vehicle_contract_email']
      @details << "The email could not be send to the user" 
      add_user_details(customer_id)
      add_user_details(sent_by_id)
      add_vehicle_contract_details(vehicle_contract_id)
      SystemError.create!(resource_type: SystemError::VEHICLECONTRACT, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: "VehicleContractMailer_vehicle_contract_email",
                          description: @details.join("\n"))
    end
  end

  def accept_notification_email(vehicle_contract_id)
    begin
      @vehicle_contract = VehicleContract.find(vehicle_contract_id)
      if @vehicle_contract.manager
        @to_address = @vehicle_contract.manager.email
      else
        @to_address = "info@bus4x4.com.au"
      end
      mail to: @to_address, subject: "Vehicle Contract Accepted - Contract #{@vehicle_contract.uid}", from: @vehicle_contract.customer.email
    rescue  => e       
      @error= e.class
      @details = ['An error occurred in VehicleContractMailer#accept_notification']
      @details << "The email could not be send to the VehicleContract manager"
      add_vehicle_contract_details(vehicle_contract_id)
      SystemError.create!(resource_type: SystemError::VEHICLECONTRACT, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: "VehicleContractMailer_accept_notification",
                          description: @details.join("\n"))
    end
  end

  def upload_notification_email(vehicle_contract_id)
    begin
      @vehicle_contract = VehicleContract.find(vehicle_contract_id)
      if @vehicle_contract.manager
        @to_address = @vehicle_contract.manager.email
      else
        @to_address = "info@bus4x4.com.au"
      end
      mail to: @to_address, subject: "Vehicle Contract Uploaded - Contract #{@vehicle_contract.uid}", from: @vehicle_contract.customer.email
    rescue  => e       
      @error= e.class
      @details = ['An error occurred in VehicleContractMailer#upload_notification_email']
      @details << "The email could not be send to the VehicleContract manager"
      add_vehicle_contract_details(vehicle_contract_id)
      SystemError.create!(resource_type: SystemError::VEHICLECONTRACT, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: "VehicleContractMailer_upload_notification_email",
                          description: @details.join("\n"))
    end
  end


  private

    def add_vehicle_contract_details(vehicle_contract_id)
      vehicle_contract = VehicleContract.find_by(id: vehicle_contract_id)
      if vehicle_contract.nil?
        @details << "Invalid vehicle contract id, id: #{vehicle_contract_id}"
      else
        @details << "Vehicle Contract Reference: #{vehicle_contract.uid}"
        quote = vehicle_contract.quote
        @details << "Quote number: #{quote.number}" if quote
      end
    end

    def add_user_details(user_id)
      user = User.find_by(id: user_id)
      if user.nil?
        @details << "Invalid user id: #{user_id}"
      else
        @details << "User email: #{user.email}"
      end
    end  
end    
