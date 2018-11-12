class EnquiryMailer < ActionMailer::Base

  default from: "noreply@bus4x4.com.au"

  def assign_notification(user_id, enquiry_id)
    begin
      @user = User.find(user_id)
      @enquiry = Enquiry.find(enquiry_id)
       mail to: @user.email,
            subject: "Enquiry Assigned [##{@enquiry.uid}]",
            from: "noreply@bus4x4.com.au"
    rescue  => e
      @error= e.class
      @details = ['An error occurred in EnquiryMailer#assign_notification']
      @details << "The email could not be send to the user"
      add_user_details(user_id)
      add_enquiry_details(enquiry_id)
      SystemError.create!(resource_type: SystemError::ENQUIRY, error_status: SystemError::ACTION_REQUIRED,
                          error: @error, user_email: @user.email, error_method: "EnquiryMailer_assign_notification",
                          description: @details.join("\n"))
    end
  end


  def notification_email(user_id, enquiry_id, message)
    begin
      @user = User.find(user_id)
      @enquiry = Enquiry.find(enquiry_id)
      @message = message.to_s
      
      if @enquiry.manager
        @from_address = @enquiry.manager.email
      else
        @from_address = current_user.email
      end
      @enquiry.attachments.where(email_sent: true).each do |a|
        attachments[a.upload_file_name] = Paperclip.io_adapters.for(a.upload).read
      end
      #ActionMailer::Base.mail(from:@from_address, to: @user.email, subject: "Enquiry Send [##{@enquiry.uid}]", body: @message.decoded).deliver
       mail to: @user.email,
            subject: "Enquiry on Bus4x4",
            from: @from_address
    rescue  => e
      @error= e.class
      @details = ['An error occurred in EnquiryMailer#notification_email']
      @details << "The email could not be send to the user"
      add_user_details(user_id)
      add_enquiry_details(enquiry_id)
      SystemError.create!(resource_type: SystemError::ENQUIRY, error_status: SystemError::ACTION_REQUIRED,
                          error: @error, user_email: @user.email, error_method: "EnquiryMailer_assign_notification",
                          description: @details.join("\n"))
    end
  end 

    def notification_email_other_recipents(email, enquiry_id, message)
      begin
        @to_address = email
        @enquiry = Enquiry.find(enquiry_id)
        @message = message
         
        if @enquiry.manager
          @from_address = @enquiry.manager.email
        else
          @from_address = current_user.email
        end
         @enquiry.attachments.where(email_sent: true).each do |a|
            attachments[a.upload_file_name] = Paperclip.io_adapters.for(a.upload).read
         end
        #ActionMailer::Base.mail(from:@from_address, to: @to_address, subject: "Enquiry Send [##{@enquiry.uid}]", body: @message).deliver
         mail to: @to_address,
              subject: "Enquiry on Bus4x4",
              from: @from_address
      rescue  => e
        @error= e.class
        @details = ['An error occurred in EnquiryMailer#notification_email_other_recipents']
        @details << "The email could not be send to the user"
        @details << email
        add_enquiry_details(enquiry_id)
        SystemError.create!(resource_type: SystemError::ENQUIRY, error_status: SystemError::ACTION_REQUIRED,
                            error: @error, user_email: @user.email, error_method: "EnquiryMailer_assign_notification",
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

    def add_enquiry_details(enquiry_id)
      enquiry = Enquiry.find_by(id: enquiry_id)
      if enquiry.nil?
        @details << "Invalid enquiry id: #{enquiry_id}"
      else
        @details << "Enquiry id: #{enquiry_id}"
      end
    end

end
