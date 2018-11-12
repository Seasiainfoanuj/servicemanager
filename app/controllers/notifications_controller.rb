class NotificationsController < ApplicationController
  include VehiclesHelper
  include NotificationTypesHelper

  before_action :authenticate_user!
  authorize_resource
  
  before_action :set_notification, only: [:show, :new, :edit, :update, :complete, :destroy, :record_action]
  before_action :set_notifiable, only: [:index]

  add_crumb("Notifications") { |instance| instance.send :notifications_path }

  def index
    session['last_request'] = '/notifications'
    @filtered_user = User.find(params[:filtered_user_id]) if params[:filtered_user_id]
    if @filtered_user
      add_crumb "Notifications", notifications_path
    end

    respond_to do |format|
      format.html
      format.json { render json: NotificationsDatatable.new(view_context, current_user, session[:notifiable_type], session[:notifiable_id]) }
    end
  end

  def show
    unless @notification.present?
      flash[:warning] = "Notification not found."
      redirect_to (session['last_request'] || notifications_path) and return
    end
    @notification.create_activity :view, owner: current_user
    session['last_request'] = "/notifications/#{@notification.id}"
    add_crumb @notification.name
    @activities = PublicActivity::Activity.order("created_at desc").where(:trackable_type => "Notification", :trackable_id => @notification.id)
  end

  def new
    initialise_notification
  end

  def create
    @notification = Notification.new(notification_params_new)
    if @notification.send_emails && 
          (@notification.recipients.none? || @notification.email_message.blank?)
      flash[:error] = "Notification cannot be created. Recipients and Message are required."
      initialise_notification
      render 'new' and return
    end  
    if @notification.save
      @notification.create_activity :create, owner: current_user
      flash[:success] = "Notification created for #{@notification.notifiable.name} - #{@notification.notification_type.event_name}."
      if @notification.send_emails == false && @notification.notification_type.emails_required
        @notification.send_emails == true
        @notification.email_message ||= default_email_message
        flash[:notice] = "Please provide recipients and change email message if needed."
        render 'edit' and return
      end
      redirect_to (session['last_request'] || notifications_path)
    else
      flash[:error] = "Notification create failed."
      initialise_notification
      render 'new'
    end
  end

  def edit
    if @notification.completed_date
      flash[:notice] = "Update not allowed. Notification has been completed."
      redirect_to (session['last_request'] || notifications_path) and return
    end
    add_crumb @notification.name, notification_path(@notification)
    add_crumb 'Edit Notification'
    @notification.email_message ||= default_email_message
  end

  def update
    notification_update_params = notification_params_new
    if @notification.notification_type.emails_required
      notification_update_params = notification_params_new.merge(send_emails: '1')
    end
    if @notification.update(notification_update_params)
      @notification.create_activity :update, owner: current_user
      flash[:success] = "Notification for #{@notification.notifiable.name} - #{@notification.notification_type.event_name} updated."
      redirect_to (session['last_request'] || notifications_path)
    else
      @notification.send_emails = false if @notification.recipients.none?
      flash[:error] = "Notification could not be updated."
      render 'edit'
    end
  end

  def record_action
    if @notification.completed_date
      flash[:notice] = "No further action required. Notification has already been completed."
      redirect_to (session['last_request'] || notifications_path) and return
    end
    add_crumb @notification.name
    add_crumb 'Record Action'
  end

  def complete
    @notification.completed_date = Date.today
    @notification.completed_by = current_user
    if @notification.notification_type.upload_required
      document_name = get_resource_document_name
      document_type = DocumentType.find_by(name: document_name)
      if document_type.nil?
        flash[:error] = "Notification cannot be completed - no document type was found with name, #{document_name}"
        render('record_action') and return
      end
      unless params["upload"]
        flash[:error] = "Notification cannot be completed - no document has been uploaded."
        render('record_action') and return
      end
    end  
    if @notification.update(notification_params)
      if @notification.notification_type.upload_required && params["upload"]
        image = Image.new(document_type_params(document_type.id))
        if image.save
          @notification.update(document_uploaded: true)
          flash[:notice] = "Document was successfully uploaded. See uploaded image in the Documents and Photos section."
        else
          flash[:error] = "The document could not be uploaded."
          render('record_action') and return
        end  
      end  
      @notification.create_activity :complete, owner: current_user
      send_completed_notification_emails attachment: image
      if @notification.notification_type.recurring
        create_follow_up_notification
        flash[:success] = "Notification has been completed. Since this is a recurring notification, revise the new notification that has been created for you."
        redirect_to edit_notification_path(@follow_up_notification)
      else
        flash[:success] = "Notification has been completed."
        redirect_to (session['last_request'] || notifications_path)
      end
    else    
      flash[:error] = "Notification could not be completed."
      render 'record_action'
    end
  end

  def destroy
    if @notification.can_be_deleted?
      @notification.destroy 
      flash[:success] = "Notification deleted."
    else
      flash[:error] = "Cannot delete notification, #{@notification.name}. Completed notifications are archived."
    end
    if session['last_request']
      if session['last_request'] == "/notifications/#{@notification.id}"
        redirect_to notifications_path
      else  
        redirect_to session['last_request']
      end
    else
      redirect_to notifications_path
    end
  end

  def update_resources
    case params[:resource_type]
    when 'Vehicle'
      resources = options_for_vehicles_and_models
    else
      return  
    end
    return if resources.nil?
    @notification_resources = "<option value=''>Please select</option>"
    resources.each do |resource|
      @notification_resources += "<option value='" + resource[1].to_s + "'>" + resource[0] + "</option>"
    end
    respond_to do |format|
      format.js
    end
  end

  def update_event_types
    return unless params[:resource_type]
    resources = options_for_notification_types(params[:resource_type])
    return if resources.nil?
    @event_names = "<option value=''>Please select</option>"
    resources.each do |resource|
      @event_names += "<option value='" + resource[1].to_s + "'>" + resource[0] + "</option>"
    end
    respond_to do |format|
      format.js
    end
  end

  private

    def set_notification
      if params[:id].present?
        @notification = Notification.find_by(id: params[:id])
      elsif params[:vehicle_id].present? && (can? :update, Vehicle)
        vehicle = Vehicle.find(params[:vehicle_id])
        notification_type = NotificationType.find_by(event_name: params['event_name']) if params['event_name'].present?
        notification_type_id = notification_type ? notification_type.id : nil
        @notification = Notification.new(notifiable: vehicle, 
            notification_type_id: notification_type_id,
            email_message: notification_type.default_message)
      else
        @notification = Notification.new
      end
    end

    def set_notifiable
      if params[:vehicle_id].present? && (can? :update, Vehicle)
        @notifiable = Vehicle.find_by(id: params[:vehicle_id])
        session[:notifiable_id] = @notifiable.id
        session[:notifiable_type] = 'Vehicle'
        add_crumb "Vehicles", vehicles_path
        add_crumb @notifiable.name, vehicle_path(@notifiable)
      elsif params.keys.length == 2
        # When Notifications is selected from the menu, all notifications are requested
        # and the expected params are: {"action"=>"index", "controller"=>"notifications"}
        session.delete(:notifiable_id)
        session.delete(:notifiable_type)
        @notifiable = nil 
      else
        @notifiable = nil
      end
    end

    def create_follow_up_notification
      notification_type = @notification.notification_type
      @follow_up_notification = Notification.create!(
        notifiable: @notification.notifiable,
        notification_type_id: @notification.notification_type_id,
        invoice_company_id: @notification.invoice_company_id,
        owner_id: @notification.owner_id,
        send_emails: @notification.send_emails,
        email_message: @notification.notification_type.default_message,
        recipients: @notification.recipients,
        due_date: @notification.due_date + notification_type.recur_period_days.days
      )
    end

    def initialise_notification
      if params[:notification].present? && params[:notification][:notification_type_id].present?
        notification_type = NotificationType.find_by(id: params[:notification][:notification_type_id])
        @notification.notification_type_id = notification_type.id if notification_type
        @notification.email_message = default_email_message
        @notification.send_emails = true if notification_type && notification_type.emails_required
      end
      @notification.recipients ||= []
    end

    def notification_params_new
      new_params = notification_params
      new_params[:recipients] = names_to_array(new_params[:recipients])
      new_params
    end

    def notification_params
      params.require(:notification).permit(
        :notifiable_id,
        :notifiable_type,
        :notification_type_id,
        :invoice_company_id,
        :owner_id,
        :due_date_field,
        :completed_date,
        :email_message,
        :send_emails,
        :recipients,
        :comments
      )
    end

    def names_to_array(names)
      return [] if names.nil?
      list = names.split(',')
      list.collect { |name| name.strip }
    end

    def default_email_message
      if @notification.notification_type
        ActionController::Base.helpers.strip_tags(@notification.notification_type.default_message)
      end
    end

    def get_resource_document_name
      case @notification.notification_type.resource_name
      when "Vehicle"
        @notification.notification_type.resource_document_type
      end
    end

    def document_type_params(document_type_id)
      { document_type_id: document_type_id, imageable_id: @notification.notifiable_id,
        imageable_type: @notification.notifiable_type, image_type: Image::DOCUMENT,
        name: @notification.notification_type.event_name,
        description: @notification.notification_type.event_name, image: params["upload"] }
    end

    def send_completed_notification_emails attachment: nil
      if @notification.send_emails
        recipient_emails = @notification.recipients
        recipient_emails << @notification.owner.email
        recipient_emails.each do |email|
          NotificationMailer.delay.task_completed_email(
            current_user.id, email, @notification.id, file: attachment)
        end
      end
    end

end  

