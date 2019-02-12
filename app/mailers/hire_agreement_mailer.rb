class HireAgreementMailer < ActionMailer::Base
  default from: "info@bus4x4.com.au"

  def hire_agreement_email(user_id, hire_agreement_id, message)
    begin
      @user = User.find(user_id)
      @hire_agreement = HireAgreement.find(hire_agreement_id)
      @message = message
      if @hire_agreement.manager
        @from_address = @hire_agreement.manager.email
      else
        @from_address = "info@bus4x4.com.au"
      end
      mail(to: @user.email, subject: "[#{BUS4X4_HIRE_COMPANY_NAME}] New Hire Agreement ##{@hire_agreement.uid}", from: @from_address) do |format|
        format.text
        format.html
      end
      rescue  => e
      @error= e.class
      @details = ['An error occurred in HireAgreementMailer#hire_agreement_email']
      @details << "The email could not be send to the HireAgreement manager"
      add_user_details(user_id)
      add_hire_agreement_details(hire_agreement_id)
      SystemError.create!(resource_type: SystemError::HIREAGREEMENT, error_status: SystemError::ACTION_REQUIRED,
                          error: @error, user_email: @user.email, error_method: "HireAgreementMailer_hire_agreement_email",
                          description: @details.join("\n"))
    end
  end

  def pickup_return_notification(user_id, hire_agreement_id, message, action)
    begin
      @user = User.find(user_id)
      @hire_agreement = HireAgreement.find(hire_agreement_id)
      @message = message
      if @hire_agreement.manager
        @from_address = @hire_agreement.manager.email
      else
        @from_address = "info@bus4x4.com.au"
      end
      subject = "[#{BUS4X4_HIRE_COMPANY_NAME}] Vehicle #{action} notification for Hire Agreement ##{@hire_agreement.uid}"
      
      mail(to: @user.email, subject: subject, from: @from_address) do |format|
        format.text
        format.html
      end
     rescue  => e
      @error= e.class
      @details = ['An error occurred in HireAgreementMailer#hire_agreement_email']
      @details << "The email could not be send to the HireAgreement manager"
      add_user_details(user_id)
      add_hire_agreement_details(hire_agreement_id)
      SystemError.create!(resource_type: SystemError::HIREAGREEMENT, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: "HireAgreementMailer_hire_agreement_email",
                          description: @details.join("\n"))
    end
  end

  def accept_notification(hire_agreement_id)
    begin
      @hire_agreement = HireAgreement.find(hire_agreement_id)
      if @hire_agreement.manager
        @to_address = @hire_agreement.manager.email
      else
        @to_address = "info@bus4x4.com.au"
      end
      mail to: @to_address, subject: "Hire Agreement Accepted - Hire Agreement #{@hire_agreement.uid}", from: @hire_agreement.customer.email
     rescue  => e
      @error= e.class
      @details = ['An error occurred in HireAgreementMailer#hire_agreement_email']
      @details << "The email could not be send to the HireAgreement manager"
      add_hire_agreement_details(hire_agreement_id)
      SystemError.create!(resource_type: SystemError::HIREAGREEMENT, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: "HireAgreementMailer_hire_agreement_email",
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

    def add_hire_agreement_details(hire_agreement_id)
      hire_agreement = HireAgreement.find_by(id: hire_agreement_id)
      if hire_agreement.nil?
        @details << "Invalid hire_agreement id: #{hire_agreement_id}"
      else
        @details << "HireAgreement id: #{hire_agreement_id}"
        if hire_agreement.manager
          @details << "HireAgreement manager email: #{hire_agreement.manager.email}" 
        else
          @details << "HireAgreement has no manager"
        end
      end
    end

end
