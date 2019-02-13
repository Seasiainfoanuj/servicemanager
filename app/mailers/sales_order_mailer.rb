class SalesOrderMailer < ActionMailer::Base
  def notification_email(user_id, current_user_id, sales_order_id, message)
    begin
      @user = User.find(user_id)
      @current_user = User.find(current_user_id)

      @sales_order = SalesOrder.find(sales_order_id)
      @message = message

      mail to: @user.email,
           subject: "Order ##{@sales_order.number}",
           from: @current_user.email
      rescue  => e       
      @error= e.class
      @details = ['An error occurred in SalesOrderMailer#notification_email']
      @details << "The email could not be send to the user"
      add_user_details(user_id)
      add_user_details(current_user_id)
      add_so_number_details(sales_order_id)
      SystemError.create!(resource_type: SystemError::SALESORDER, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: "SalesOrderMailer_notification_email",
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

    def add_so_number_details(sales_order_id)
      sales_order = SalesOrder.find_by(id: sales_order_id)
      if sales_order.nil?
        @details << "Invalid sales_order id: #{sales_order_id}"
      else
        @details << "SalesOrder number: #{sales_order.number}"
      end
    end

end
