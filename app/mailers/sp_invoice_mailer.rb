class SpInvoiceMailer < ActionMailer::Base
  def notification_email(user_id, sp_invoice_id)
    begin
      @user = User.find(user_id)
      @invoice = SpInvoice.find(sp_invoice_id)
      mail to: @user.email,
      subject: "Invoice submitted for #{@invoice.job_type.titleize} ##{@invoice.job.uid}",
      from: "noreply@bus4x4.com.au"
    rescue  => e
      @error= e.class
      @details = ['An error occurred in SpInvoiceMailer#notification_email']
      @details << "The email could not be send to the user"
      add_user_details(user_id)
      add_spinvoice_details(sp_invoice_id)
      SystemError.create!(resource_type: SystemError::SPINVOICE, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: "SpInvoiceMailer_notification_email", 
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

    def add_spinvoice_details(sp_invoice_id)
      sp_invoice = SpInvoice.find_by(id: sp_invoice_id)
      if sp_invoice.nil?
        @details << "Invalid SpInvoice id: #{sp_invoice_id}"
      else
        @details << "SpInvoice id: #{sp_invoice_id}"
        if sp_invoice.job_type
          @details << "SpInvoice job_type: #{sp_invoice.job_type.titleize}" 
        else
          @details << "SpInvoice has no Job Type"
        end
        if sp_invoice.job
          @details << "SpInvoice job uid: #{sp_invoice.job.uid}" 
        else
          @details << "SpInvoice has no Job"
        end
      end
    end

end
