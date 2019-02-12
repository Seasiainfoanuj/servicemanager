class PoRequestMailer < ActionMailer::Base
  def notification_email(user_id, current_user_id, po_request_id, message)
    begin
      @user = User.find(user_id)
      @current_user = User.find(current_user_id)

      @po_request = PoRequest.find(po_request_id)
      @message = message

      mail to: @user.email,
           subject: "PO Request ##{@po_request.uid}",
           from: @current_user.email
     rescue  => e       
      @error= e.class
      @details = ['An error occurred in PoRequestMailer#notification_email']
      @details << "The email could not be send to a user"
      add_user_details(user_id)
      add_user_details(current_user_id)
      add_porequest_details(po_request_id)
      SystemError.create!(resource_type: SystemError::POREQUEST, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: "PoRequestMailer#notification_email",
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

    def add_porequest_details(po_request_id)
      po_request = PoRequest.find_by(id: po_request_id)
      if po_request.nil?
        @details << "Invalid PO Request id: #{po_request_id}"
      else
        @details << "PO Request id: #{po_request_id}"
      end
    end

end
