class VehicleLogMailer < ActionMailer::Base

  def notification_email(user_id, vehicle_log_id)
    begin
      @user = User.find(user_id)
      @vehicle_log = VehicleLog.find(vehicle_log_id)
      @from_address = "noreply@bus4x4.com.au"
      mail to: @user.email, subject: "Attention Required [Logbook Entry REF ##{@vehicle_log.uid}]", from: @from_address
    rescue  => e       
      @error= e.class
      @details = ['An error occurred in VehicleLogMailer#notification_email']
      @details << "The email could not be send to the user"
      add_user_details(user_id)
      add_vehicle_log_details(vehicle_log_id)
      SystemError.create!(resource_type: SystemError::VEHICLELOG, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: "VehicleLogMailer_notification_email",
                          description: @details.join("\n"))
    end
  end

  private
    def add_user_details(user_id)
      user = User.find_by(id: user_id)
      if user.nil?
        @details << "Invalid user id: #{user_id}"
      else
        @details << "User email: #{user.email}"
      end
    end  

    def add_vehicle_log_details(vehicle_log_id)
      vehicle_log = VehicleLog.find_by(id: vehicle_log_id)
      if vehicle_log.nil?
        @details << "Invalid VehicleLog id: #{vehicle_log_id}"
      else
        @details << "VehicleLog uid: #{vehicle_log.uid}"
      end
    end

end
