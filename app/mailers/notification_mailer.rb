class NotificationMailer < ActionMailer::Base

  def notification_email(recipient_email, notification_id)
    begin
      @notification = Notification.find(notification_id)
      @sent_by = @notification.owner
      @recipient = User.find_by(email: recipient_email)
      @message = @notification.email_message
      mail to: @recipient.email, subject: @notification.name, from: @sent_by.email
    rescue  => e       
      @error= e.class
      @details = ['An error occurred in NotificationMailer#notification_email']
      @details << "The email could not be send to the user" 
      @details << "Recipient email: #{recipient_email}"
      @details << "Notification id: #{notification_id}"
      SystemError.create!(resource_type: SystemError::NOTIFICATION, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: "NotificationMailer_notification_email",
                          description: @details.join("\n"))
    end
  end

  def task_completed_email(current_user_id, recipient_email, notification_id, file: nil)
    begin
      @notification = Notification.find(notification_id)
      @sent_by = User.find_by(id: current_user_id)
      @recipient = User.find_by(email: recipient_email)
      @message = @notification.email_message
      attachments[file.image_file_name] = Paperclip.io_adapters.for(file.image).read if file
      mail to: @recipient.email, subject: @notification.name, from: @sent_by.email
    rescue  => e       
      @error= e.class
      @details = ['An error occurred in NotificationMailer#task_completed_email']
      @details << "The email could not be send to the user" 
      @details << "Current user id: #{current_user_id}"
      @details << "Recipient email: #{recipient_email}"
      SystemError.create!(resource_type: SystemError::NOTIFICATION, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: "NotificationMailer_task_completed_email",
                          description: @details.join("\n"))
    end
  end

end

