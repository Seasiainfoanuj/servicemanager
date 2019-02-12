class HireQuoteMailer < ActionMailer::Base

  def quote_email(user_id, hire_quote_id, message)
    begin
      @customer = User.find(user_id)
      @quote = HireQuote.find(hire_quote_id)
      @message = message
      @manager = @quote.manager.user
      mail to: @customer.email, subject: "[#{BUS4X4_HIRE_COMPANY_NAME}] New quote #{@quote.reference}", from: @manager.email
    rescue  => e   
      @error= e.class
      @details = ['An error occurred in HireQuoteMailer#quote_email']
      @details << "The email could not be send to the user"
      add_user_details(user_id)
      add_quote_details(hire_quote_id)
      SystemError.create!(resource_type: SystemError::HIREQUOTE, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: "HireQuoteMailer_quote_email",
                          description: @details.join("\n"))
    end
  end

  def accept_notification_email(manager_id, quote_id)
    begin
      @quote = HireQuote.find(quote_id)
      @customer = @quote.authorised_contact
      @manager = User.find_by(id: manager_id)
      @to_address = @manager.email
      mail to: @to_address, subject: "Quote Accepted - Quote Ref: #{@quote.reference}", from: @quote.authorised_contact.email
    rescue  => e       
      @error= e.class
      @details = ['An error occurred in HireQuoteMailer#accept_notification_email']
      @details << "The email could not be send to the user"
      add_user_details(manager_id)
      add_quote_details(quote_id)
      SystemError.create!(resource_type: SystemError::HIREQUOTE, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: "HireQuoteMailer_accept_notification_email",
                          description: @details.join("\n"))
    end
  end

  def request_changes_email(quote_id, user_id, message)
    begin
      @quote = HireQuote.find(quote_id)
      @message = message
      @sender = User.find(user_id)
      @manager = @quote.manager.user
      mail to: @manager.email, subject: "Requested Changes - Hire Quote #{@quote.reference}", from: @sender.email
    rescue  => e       
      @error= e.class
      @details = ['An error occurred in HireQuoteMailer#request_changes_email']
      @details << "The email could not be send to the user"
      add_quote_details(quote_id)
      add_user_details(user_id)
      SystemError.create!(resource_type: SystemError::HIREQUOTE, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: "HireQuoteMailer_request_changes_email",
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

    def add_quote_details(quote_id)
      quote = HireQuote.find_by(id: quote_id)
      if quote.nil?
        @details << "Invalid quote id: #{quote_id}"
      else
        @details << "Quote id: #{quote_id}, Quote uid: #{quote.uid}"
      end
    end

end