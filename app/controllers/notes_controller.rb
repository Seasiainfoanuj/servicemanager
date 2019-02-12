class NotesController < ApplicationController
  before_action :set_note, only: [:update, :destroy]

  def create
    @note = Note.new(note_params)
    recipient_params = build_recipient_params
    if recipient_params.any?
      @note.recipients.build(recipient_params)
    end
    if @note.save
      if @note.sched_time && recipient_params.any?
        @note.create_activity :schedule
      end
      @note.create_activity :create, owner: current_user
      flash[:success] = "Note was successfully created."
      redirect_to request.referer + "#note-#{@note.id}"
    else
      errors = ""
      @note.errors.full_messages.each do |msg|
        errors += "- #{msg}<br>"
      end
      flash[:error] = "The following errors prevented note from being created: <br>#{errors.to_s}".html_safe
      flash[:note_comments] = @note.comments.html_safe if @note.comments.present?
      redirect_to request.referer
    end
  end

  def update
    recipient_params = build_recipient_params
    if recipient_params.any?
      @note.recipients.build(recipient_params)
    end
    @note.recipients.delete_all
    @note.recipients.build(recipient_params)
    if @note.update(note_params)
      @note.create_activity :update, owner: current_user
      flash[:success] = "Note was successfully updated."
      redirect_to request.referer + "#note-#{@note.id}"
    else
      errors = ""
      @note.errors.full_messages.each do |msg|
        errors += "- #{msg}<br>"
      end
      flash[:error] = "The following errors prevented note from being updated: <br>#{errors.to_s}".html_safe
      flash[:note_comments] = @note.comments.html_safe if @note.comments.present?
      redirect_to request.referer
    end
  end

  def destroy
    if @note.destroy
      flash[:notice] = "Note removed."
    end
    redirect_to @note.resource
  end

  def send_notifications
    note = Note.find(params["note"]["note_id"])
    if note.nil?
      flash[:error] = "Unexpected exception occurred: Note could not be found"
      redirect_to request.referer
      return
    end
    if note.sched_time.to_date < Time.now.to_date
      flash[:error] = "The due date of the note has already expired. Reminders will therefore not be sent."
      redirect_to request.referer
      return
    end  
    message = note.comments
    subject = note.resource.resource_name
    flash_message = "Email notifications have been sent to "
    note.recipients.each do |recipient|
      NoteMailer.delay.notification_email(recipient.user.id, note.id, message, subject)
      flash_message += "& #{recipient.user.email}"
    end
    note.create_activity :reminder, owner: current_user
    flash[:success] = flash_message
    redirect_to request.referer
  end

  private

    def build_recipient_params
      recipients = []
      @note.reminder_status = Note::NO_REMINDER
      if params["recipients_attributes"]
        params["recipients_attributes"].each do |user_id|
          recipients << Hash[user_id: user_id]
        end
        @note.reminder_status = Note::SCHEDULED
      end
      puts "NotesController#build_recipient_params: #{recipients.inspect}"
      recipients
    end

    def set_note
      @note = Note.find(params[:id])
    end

    def note_params
      params.require(:note).permit(
        :id,
        :resource_id,
        :resource_type,
        :author_id,
        :public,
        :comments,
        :sched_time,
        :selected_users,
        :recipients_attributes,
        :note_id,
        uploads_attributes: [:id, :note, :upload, :_destroy]
      )
    end
end
