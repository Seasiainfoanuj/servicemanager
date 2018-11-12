class OffHireJobMailer < ActionMailer::Base
  default from: "workorders@bus4x4.com.au"

  def notification_email(user_id, off_hire_job_id, message)
    begin
      @user = User.find(user_id)
      @off_hire_job = OffHireJob.find(off_hire_job_id)
      @off_hire_report = @off_hire_job.off_hire_report
      @message = message
      if @off_hire_job.manager
        @from_address = @off_hire_job.manager.email
      else
        @from_address = "workorders@bus4x4.com.au"
      end
      mail to: @user.email, subject: "Off Hire Job #{@off_hire_job.status.capitalize}", from: @from_address
    rescue  => e       
      @error= e.class
      @details = ['An error occurred in OffHireJobMailer#notification_email']
      @details << "The email could not be send to the user"
      add_user_details(user_id)
      add_offhirejob_details(off_hire_job_id)
      SystemError.create!(resource_type: SystemError::OFFHIREJOB, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: "OffHireJobMailer_notification_email",
                          description: @details.join("\n"))
    end
  end

  def off_hire_job_notification(user_id, off_hire_job_id, action_type)
    begin
      @user = User.find(user_id)
      @off_hire_job = OffHireJob.find(off_hire_job_id)
      @off_hire_report = @off_hire_job.off_hire_report
      if @off_hire_job.manager
        @from_address = @off_hire_job.manager.email
      else
        @from_address = "workorders@bus4x4.com.au"
      end
      @action_type = action_type
      mail to: @user.email, subject: "Off Hire Job #{action_type.capitalize}", from: @from_address
    rescue  => e       
      @error= e.class
      @details = ['An error occurred in OffHireJobMailer#off_hire_job_notification']
      @details << "The email could not be send to the user"
      add_user_details(user_id)
      add_offhirejob_details(off_hire_job_id)
      @details << "Action type: #{action_type}"
      SystemError.create!(resource_type: SystemError::OFFHIREJOB, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: "OffHireJobMailer_off_hire_job_notification",
                          description: @details.join("\n"))
    end
  end

  def reminder_email(user_id, off_hire_job_id)
    begin
      @user = User.find(user_id)
      @off_hire_job = OffHireJob.find(off_hire_job_id)
      @off_hire_report = @off_hire_job.off_hire_report
      if @off_hire_job.manager
        @from_address = @off_hire_job.manager.email
      else
        @from_address = "workorders@bus4x4.com.au"
      end
      mail to: @user.email, subject: "Off Hire Job Reminder", from: @from_address
    rescue  => e       
      @error= e.class
      @details = ['An error occurred in OffHireJobMailer#reminder_email']
      @details << "The email could not be send to the user"
      add_user_details(user_id)
      add_offhirejob_details(off_hire_job_id)
      SystemError.create!(resource_type: SystemError::OFFHIREJOB, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: "OffHireJobMailer_reminder_email",
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

    def add_offhirejob_details(off_hire_job_id)
      off_hire_job = OffHireJob.find_by(id: off_hire_job_id)
      if off_hire_job.nil?
        @details << "Invalid off-hire job id: #{off_hire_job_id}"
      else
        @details << "OffHireJob id: #{off_hire_job_id}"
        if off_hire_job.manager
          @details << "OffHireJob manager email: #{off_hire_job.manager.email}" 
        else
          @details << "OffHireJob has no manager"
        end
      end
    end

end
