class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  add_crumb "Home", '/'

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def after_sign_out_path_for(resource_or_scope)
    new_session_path(resource_name)
  end

  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  before_filter :set_user_associations, only: [:show, :edit, :index, :update]

  def set_user_associations
    return unless params[:filtered_user_id] || (params[:controller] == "users" && params[:id])
    begin
      @filtered_user = User.find(params[:filtered_user_id] || params[:id])
    rescue
      @filtered_user = nil
      return
    end
    exclude = %w[ messages addresses licences notes ]
    @replace = {'stocks' => 'stock'}
    @associations = User.reflect_on_all_associations(:has_many).collect { |a| a.table_name.to_s }.uniq.sort - exclude
    @ability = Ability.new(@filtered_user)
  end

  before_filter :set_turbolinks

  def set_turbolinks
    # Disable turbolinks for all views that have dhtmlx scheduler (not compatible)
    if params[:controller] == "schedule_views" && params[:action] == "show" ||
       params[:controller] == "builds" && params[:action] == "show" ||
       params[:controller] == "build_orders" && params[:action] == "new" ||
       params[:controller] == "build_orders" && params[:action] == "edit" ||
       params[:controller] == "hire_agreements" && params[:action] == "new" ||
       params[:controller] == "hire_agreements" && params[:action] == "edit" ||
       params[:controller] == "off_hire_jobs" && params[:action] == "new" ||
       params[:controller] == "off_hire_jobs" && params[:action] == "edit" ||
       params[:controller] == "vehicles" && params[:action] == "schedule" ||
       params[:controller] == "schedule" && params[:action] == "index"
      @turbolinks = false
    else
      @turbolinks = true
    end
  end
  
  def new_workorder_uid
    'WO-' + (0...2).map{ ('A'..'Z').to_a[rand(26)] }.join + (0...4).map{ (1..9).to_a[rand(9)] }.join
  end
end
