class WorkorderMailer < ActionMailer::Base

  def notification_email(user_id, workorder_id, message)
    begin
      @user = User.find(user_id)
      @workorder = Workorder.find(workorder_id)
      @message = message
      if @workorder.manager
        @from_address = @workorder.manager.email
      else
        @from_address = "workorders@bus4x4.com.au"
      end
      mail to: @user.email, subject: "Workorder #{@workorder.status.capitalize}", from: @from_address
    rescue  => e       
      @error= e.class
      @details = ['An error occurred in WorkorderMailer#notification_email']
      @details << "The email could not be send to the user"
      add_user_details(user_id)
      add_workorder_details(workorder_id)
      SystemError.create!(resource_type: SystemError::WORKORDER, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: " WorkorderMailer_notification_email",
                          description: @details.join("\n"))
    end
  end

  def workorder_notification(user_id, workorder_id, action_type)
    begin
      @user = User.find(user_id)
      @workorder = Workorder.find_by(id: workorder_id)
      return if @workorder.nil?
      if @workorder.manager
        @from_address = @workorder.manager.email
      else
        @from_address = "workorders@bus4x4.com.au"
      end
      @action_type = action_type
      mail to: @user.email, subject: "Workorder #{action_type.capitalize}", from: @from_address
     rescue  => e      
      @error= e.class
      @details = ['An error occurred in WorkorderMailer#workorder_notification']
      @details << "The email could not be send to the user"
      add_user_details(user_id)
      @details << "Action type: #{action_type}"
      SystemError.create!(resource_type: SystemError::WORKORDER, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: " WorkorderMailer_notification", 
                          description: @details.join("\n"))
    end
  end

  def workorder_reminder(user_id, workorder_id)
    begin
      @user = User.find(user_id)
      @workorder = Workorder.find(workorder_id)
      if @workorder.manager
        @from_address = @workorder.manager.email
      else
        @from_address = "workorders@bus4x4.com.au"
      end
      mail to: @user.email, subject: "Workorder Reminder", from: @from_address
      rescue  => e      
      @error= e.class
      @details = ['An error occurred in WorkorderMailer#workorder_reminder']
      @details << "The email could not be send to the user"
      add_user_details(user_id)
      add_workorder_details(workorder_id)
      SystemError.create!(resource_type: SystemError::WORKORDER, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: " WorkorderMailer_workorder_reminder", 
                          description: @details.join("\n"))
    end
  end

  def notification_email_others(email, workorder_id, message)
    begin
      @workorder = Workorder.find(workorder_id)
      @message = message
      if @workorder.manager
        @from_address = @workorder.manager.email
      else
        @from_address = "workorders@bus4x4.com.au"
      end
      @user = User.find_by(email: email)
      raise ArgumentError, "Invalid email: #{email}" if @user.nil?
      mail to: email, subject: "Workorder #{@workorder.status.capitalize}", from: @from_address
     rescue  => e     
      @error= e.class
      @details = ['An error occurred in WorkorderMailer#notification_email_others']
      @details << "The email could not be send to the user"
      add_user_details_from_email(email)
      add_workorder_details(workorder_id)
      SystemError.create!(resource_type: SystemError::WORKORDER, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: " WorkorderMailer_notification_email_others",
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

    def add_workorder_details(workorder_id)
      workorder = Workorder.find_by(id: workorder_id)
      if workorder.nil?
        @details << "Invalid workorder id: #{workorder_id}"
      else
        @details << "Workorder uid: #{workorder.uid}"
        if workorder.manager
          @details << "Workorder manager email: #{workorder.manager.email}" 
        else
          @details << "Workorder has no manager"
        end
        @details << @message if @message
      end
    end

    def add_user_details_from_email(email)
      user = User.find_by(email: email)
      if user.nil?
        @details << "Invalid user email: #{email}"
      else
        @details << "User email: #{user.email}"
      end
    end

end
