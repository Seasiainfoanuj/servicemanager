class NotificationTypesController < ApplicationController
  include NotificationTypesHelper

  before_action :authenticate_user!
  authorize_resource
  
  before_action :set_notification_type, only: [:show, :edit, :update, :destroy]

  add_crumb("Notification Types") { |instance| instance.send :notification_types_path }

  def index
    @notification_types = NotificationType.all
  end

  def show
    add_crumb notification_type_label(@notification_type) 
    # @activities = PublicActivity::Activity.order("created_at desc").where(:trackable_type => "Enquiry", :trackable_id => @enquiry.id)
  end

  def new
    @notification_type = NotificationType.new
    add_crumb 'New'
  end

  def create
    @notification_type = NotificationType.new(notification_type_params)
    if params['notify_periods']
      @notification_type.notify_periods = array_from_periods(params['notify_periods'])
    end
    if @notification_type.save
       @notification_type.create_activity :create, owner: current_user
      flash[:success] = "Notification Type created."
      redirect_to(action: 'index')
    else
      flash[:error] = "Notification Type could not be created."
      render 'new'
    end  
  end

  def edit
    add_crumb "#{@notification_type.resource_name}/ #{@notification_types}", notification_type_path(@notification_type)
    add_crumb 'Edit'
  end

  def update
    if params['notify_periods']
      @notification_type.notify_periods = array_from_periods(params['notify_periods'])
    end
    if @notification_type.update(notification_type_params)
       @notification_type.create_activity :update, owner: current_user
      flash[:success] = "Notification Type updated."
      redirect_to(action: 'index')
    else
      flash[:error] = "Notification Type could not be updated."
      render 'edit'
    end
  end

  def destroy
    @notification_type.destroy
    flash[:success] = "Notification Type deleted."
    redirect_to(action: 'index')
  end

  private

    def set_notification_type
      @notification_type = NotificationType.find(params[:id])
    end

    def notification_type_params
      params.require(:notification_type).permit(
        :resource_name,
        :event_name,
        :recurring,
        :emails_required,
        :label_color,
        :default_message,
        :recur_period_days,
        :upload_required,
        :resource_document_type
      )
    end

end