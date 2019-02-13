class StockRequestMailer < ActionMailer::Base
  def notification_email(user_id, stock_request_id, message)
    begin
      @user = User.find(user_id)
      @stock_request = StockRequest.find(stock_request_id)
      @message = message

      mail to: @user.email,
           subject: "Stock request from #{@stock_request.invoice_company.name}",
           from: "info@bus4x4.com.au"
      rescue  => e       
      @error= e.class
      @details = ['An error occurred in StockRequestMailer#notification_email']
      @details << "The email could not be send to the user"
      add_user_details(user_id)
      add_stock_request_details(stock_request_id)
      SystemError.create!(resource_type: SystemError::STOCKREQUEST, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: "StockRequestMailer_notification_email",
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

    def add_stock_request_details(stock_request_id)
      stock_request = StockRequest.find_by(id: stock_request_id)
      if stock_request.nil?
        @details << "Invalid stock_request id: #{stock_request_id}"
      else
        @details << "StockRequest id: #{stock_request_id}"
        if stock_request.invoice_company
          @details << "Invoice company name: #{stock_request.invoice_company.name}"
        else
          @details << "StockRequest has no Invoice Company"
        end
      end  
    end
end
