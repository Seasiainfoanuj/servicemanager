class BuildOrderMailer < ActionMailer::Base
  
  default from: "workorders@bus4x4.com.au"

  def notification_email(user_id, build_order_id, message)
    begin
      @user = User.find(user_id)
      @build_order = BuildOrder.find(build_order_id)
      @build = @build_order.build
      @message = message
      if @build_order.manager
        @from_address = @build_order.manager.email
      else
        @from_address = "workorders@bus4x4.com.au"
      end
      mail to: @user.email, subject: "Build Order #{@build_order.status.capitalize}", from: @from_address
    rescue  => e
      @error= e.class
      @details = ['An error occurred in BuildOrderMailer#notification_email']
      @details << "The email could not be send to the user"
      add_user_details(user_id)
      add_buildorder_details(build_order_id)
      SystemError.create!(resource_type: SystemError::BUILDORDER, error_status: SystemError::ACTION_REQUIRED, 
                           error: @error, user_email: @user.email, error_method: "BuildOrderMailer_notification_email", 
                           description: @details.join("\n"))
    end
  end

  def build_order_notification(user_id, build_order_id, action_type)
    begin
      @user = User.find(user_id)
      @build_order = BuildOrder.find(build_order_id)
      @build = @build_order.build
      if @build_order.manager
        @from_address = @build_order.manager.email
      else
        @from_address = "workorders@bus4x4.com.au"
      end
      @action_type = action_type
      mail to: @user.email, subject: "Build Order #{action_type.capitalize}", from: @from_address
    rescue  => e
      @error= e.class
      @details = ['An error occurred in BuildOrderMailer#build_order_notification']
      @details << "The email could not be send to the user"
      add_user_details(user_id)
      add_buildorder_details(build_order_id)
      @details << "Action type: #{action_type}"
      SystemError.create!(resource_type: SystemError::BUILDORDER, error_status: SystemError::ACTION_REQUIRED,
                          error: @error, user_email: @user.email, error_method: " BuildOrderMailer_build_order_notification",
                          description: @details.join("\n"))
    end
  end

  def reminder_email(user_id, build_order_id)
    begin
      @user = User.find(user_id)
      @build_order = BuildOrder.find(build_order_id)
      @build = @build_order.build
      if @build_order.manager
        @from_address = @build_order.manager.email
      else
        @from_address = "workorders@bus4x4.com.au"
      end
      mail to: @user.email, subject: "Build Order Reminder", from: @from_address
    rescue  => e
      @error= e.class
      @details = ['An error occurred in BuildOrderMailer#reminder_email']
      @details << "The email could not be send to the user"
      add_user_details(user_id)
      add_buildorder_details(build_order_id)
      SystemError.create!(resource_type: SystemError::BUILDORDER, error_status: SystemError::ACTION_REQUIRED,
                          error: @error, user_email: @user.email, error_method: "BuildOrderMailer_reminder_email",
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

    def add_buildorder_details(buildorder_id)
      buildorder = BuildOrder.find_by(id: buildorder_id)
      if buildorder.nil?
        @details << "Invalid buildorder id: #{buildorder_id}"
      else
        @details << "Buildorder id: #{buildorder_id}"
        if buildorder.manager
          @details << "Buildorder manager email: #{buildorder.manager.email}" 
        else
          @details << "Buildorder has no manager"
        end
      end
    end

end
