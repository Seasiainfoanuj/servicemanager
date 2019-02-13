class NoteMailer < ActionMailer::Base

  def notification_email(recipient_id, note_id, message, subject)
    begin
      @recipient = User.find(recipient_id)
      @note = Note.find(note_id)
      @message = message
      @from_address = @note.author.email
      mail to: @recipient.email, subject: "Reminder on: #{subject}", from: @from_address
    rescue  => e 
      @error= e.class
      @details = ['An error occurred in NoteMailer#notification_email']
      @details << "The email could not be send to the Note recipient"
      add_user_details(recipient_id)
      add_notification_details(note_id)
      @details << "Subject: #{subject}"
      SystemError.create!(resource_type: SystemError::NOTE, error_status: SystemError::ACTION_REQUIRED, 
                          error: @error, user_email: @user.email, error_method: "NoteMailer_notification_email",
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

    def add_notification_details(note_id)
      note = Note.find_by(id: note_id)
      if note.nil?
        @details << "Invalid note id: #{note_id}"
      else
        @details << "Note id: #{note_id}"
        if note.author
          @details << "Note author email: #{note.author.email}" 
        else
          @details << "Note has no author"
        end
      end
    end

end

