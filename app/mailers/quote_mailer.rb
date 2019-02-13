class QuoteMailer < ActionMailer::Base

  default from: "info@bus4x4.com.au"
  #layout'mailer'
  
  def quote_email(user_id, quote_id, message)
    begin
      @user = User.find(user_id)
      @quote = Quote.find(quote_id)
      @message = message
      if @quote.manager
        @from_address = @quote.manager.email
      else
        @from_address = "info@bus4x4.com.au"
      end
      @quote.attachments.each do |a|
        attachments[a.upload_file_name] = Paperclip.io_adapters.for(a.upload).read
      end
       mail(to: @user.email, subject: "[#{@quote.invoice_company.name}] New quote #{@quote.number}", from: @from_address) do |format|
        format.text
        format.html
      end
    rescue  => e       
      @error= e.class
      @details = ['An error occurred in QuoteMailer#quote_email']
      @details << "The email could not be send to the user"
      add_user_details(user_id)
      add_quote_details(quote_id)
      SystemError.create!(resource_type: SystemError::QUOTE, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: "QuoteMailer#quote_email",
                          description: @details.join("\n"))
    end
  end

  def request_changes_email(quote_id, message)
    begin
      @quote = Quote.find(quote_id)
      @message = message
      if @quote.manager
        @to_address = @quote.manager.email
      else
        @to_address = "info@bus4x4.com.au"
      end
      mail to: @to_address, subject: "Requested Changes - Quote #{@quote.number}", from: @quote.customer.email
    rescue  => e       
      @error= e.class
      @details = ['An error occurred in QuoteMailer#request_changes_email']
      @details << "The email could not be send to the user"
      add_quote_details(quote_id)
      SystemError.create!(resource_type: SystemError::QUOTE, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: "QuoteMailer_request_changes_email",
                          description: @details.join("\n"))
    end
  end

  def accept_notification_email(user_id, quote_id)
    begin
      @quote = Quote.find(quote_id)
      @user = User.find(user_id) if user_id.present?
      if @user
        @to_address = @user.email
      else
        @to_address = "info@bus4x4.com.au"
      end
      mail(to: @to_address, subject: "Quote Accepted - Quote #{@quote.number}", from: @quote.customer.email)do |format|
        format.text
      end
    rescue  => e       
      @error= e.class
      @details = ['An error occurred in QuoteMailer#accept_notification_email']
      @details << "The email could not be send to the user"
      add_user_details(user_id)
      add_quote_number_details(quote_id)
      SystemError.create!(resource_type: SystemError::QUOTE, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: "QuoteMailer_accept_notification_email",
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
      quote = Quote.find_by(id: quote_id)
      if quote.nil?
        @details << "Invalid quote id: #{quote_id}"
      else
        @details << "Quote id: #{quote_id}"
        if quote.manager
          @details << "Quote manager email: #{quote.manager.email}" 
        else
          @details << "Quote has no manager"
        end
      end
    end

    def add_quote_number_details(quote_id)
      quote = Quote.find_by(id: quote_id)
      if quote.nil?
        @details << "Invalid quote id: #{quote_id}"
      else
        @details << "Quote number: #{quote.number}"
      end
    end

end
