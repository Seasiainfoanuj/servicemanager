class ScheduleViewsController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource

  before_action :set_schedule_view, only: [:show, :edit, :update, :destroy ]

  def index
    #@schedule_views = ScheduleView.all
  end

  def search
    @search = Search.new
    add_crumb 'Search'
  end

  def submit
    @search = Search.new(search_params)
    @search.date_from = @search.date_from.to_time
    @search.date_until = @search.date_until.to_time
    session[:search_params] = @search.instance_values
    flash[:search] = 'filtered'
    redirect_to "/schedule_views/#{search_params['view_type']}"
  end

  def show
    session['last_request'] = "/schedule_views/#{params[:id]}"
    session.delete(:search_params) unless flash[:search] == 'filtered'
    # @vehicle_ids = @schedule_view.vehicles.where(formatted_search_terms).select('vehicles.id')
  end

  def vehicles
    puts "\nScheduleViewsController#vehicles -------"
    authorize! :view_vehicles, ScheduleView
    @schedule_view = ScheduleView.find(params[:schedule_view_id])
    @vehicles = @schedule_view.vehicles.where(formatted_search_terms).order('vehicle_schedule_views.position ASC')

    # Produces wrong results - something must be wrong here:
    # @vehicles = Vehicle.includes(:schedule_views, model: :make)
    #                                   .where(vehicle_schedule_views: {id: @schedule_view.id})
    #                                   .where(formatted_search_terms)
    #                                   .order('vehicle_schedule_views.position ASC')
  end

  def hire_agreement_data
    puts "\nScheduleViewsController#hire_agreement_data --------"
    # Results, before change: Completed 200 OK in 1865ms (Views: 1800.3ms | ActiveRecord: 53.3ms)
    #                         Completed 200 OK in 1999ms (Views: 1936.5ms | ActiveRecord: 52.6ms)
    # Results, after change: Completed 200 OK in 436ms (Views: 417.0ms | ActiveRecord: 8.8ms)
    #                        Completed 200 OK in 471ms (Views: 451.6ms | ActiveRecord: 7.2ms)
    #                        Completed 200 OK in 501ms (Views: 477.9ms | ActiveRecord: 8.0ms)
    #                        Completed 200 OK in 486ms (Views: 462.8ms | ActiveRecord: 8.2ms)
    authorize! :view_hire_agreements, ScheduleView
    if session[:search_params].present?
      search_terms = formatted_search_terms
      # Old code:
      # @hire_agreements = HireAgreement.joins(vehicle: :schedule_views)
      #                                 .where(search_terms)
      #                                 .where(hire_agreement_period(@search.date_from, @search.date_until))
      #                                 .where(schedule_views: {id: params[:schedule_view_id]})
      #                                 .select(hire_agreement_fields)

      # New code:
      @hire_agreements = HireAgreement.includes(vehicle: [:model, :schedule_views], customer: :representing_company)
                                      .where(search_terms)
                                      .where(hire_agreement_period(@search.date_from, @search.date_until))
                                      .where(schedule_views: {id: params[:schedule_view_id]})
    else
      # Old code:
      # @hire_agreements = HireAgreement.joins(vehicle: :schedule_views)
      #                                 .where(schedule_views: {id: params[:schedule_view_id]})
      #                                 .select(hire_agreement_fields)

      # New code:
      @hire_agreements = HireAgreement.includes(vehicle: [:model, :schedule_views], customer: :representing_company)
                                      .where(schedule_views: {id: params[:schedule_view_id]})
    end
  end

  def workorder_data
    puts "\nScheduleViewsController#workorder_data ----------"
    # Results, before change: Completed 200 OK in 16018ms (Views: 15829.0ms | ActiveRecord: 172.6ms)
    #                         Completed 200 OK in 17236ms (Views: 16922.6ms | ActiveRecord: 297.2ms)
    # Results, after change: Completed 200 OK in 1335ms (Views: 1247.4ms | ActiveRecord: 61.3ms)
    #                        Completed 200 OK in 1375ms (Views: 1328.9ms | ActiveRecord: 32.8ms)
    #                        Completed 200 OK in 1477ms (Views: 1421.3ms | ActiveRecord: 38.0ms)
    #                        Completed 200 OK in 1470ms (Views: 1419.0ms | ActiveRecord: 36.9ms)
    authorize! :view_workorders, ScheduleView
    if session[:search_params].present?
      search_terms = formatted_search_terms
      # Old code:
      # @workorders = Workorder.joins(vehicle: :schedule_views)
      #                         .where(search_terms)
      #                         .where(workorder_period(@search.date_from, @search.date_until))
      #                         .where(schedule_views: {id: params[:schedule_view_id]})
      #                         .select(workorder_fields)
      # New code:
      @workorders = Workorder.includes(:type, service_provider: :representing_company, vehicle: [:schedule_views, model: :make])
                              .where(search_terms)
                              .where(workorder_period(@search.date_from, @search.date_until))
                              .where(schedule_views: {id: params[:schedule_view_id]})
    else
      # Old code:
      # @workorders = Workorder.joins(vehicle: :schedule_views)
      #                         .where(schedule_views: {id: params[:schedule_view_id]})
      #                         .select(workorder_fields)
      # New code:
      @workorders = Workorder.includes(:type, service_provider: :representing_company, vehicle: [:schedule_views, model: :make])
                              .where(schedule_views: {id: params[:schedule_view_id]})
    end
  end

  def build_order_data
    puts "\nScheduleViewsController#build_order_data ----------"
    # Results, before change: Completed 200 OK in 277ms (Views: 238.4ms | ActiveRecord: 8.7ms)
    #                         Completed 200 OK in 274ms (Views: 231.0ms | ActiveRecord: 8.8ms)
    # Results, after change: Completed 200 OK in 339ms (Views: 197.2ms | ActiveRecord: 7.6ms)
    #                        Completed 200 OK in 231ms (Views: 190.7ms | ActiveRecord: 7.7ms)
    #                        Completed 200 OK in 230ms (Views: 186.1ms | ActiveRecord: 8.1ms)
    #                        Completed 200 OK in 238ms (Views: 193.3ms | ActiveRecord: 8.2ms)
    authorize! :view_build_orders, ScheduleView
    if session[:search_params].present?
      search_terms = formatted_search_terms
      # Old code:
      # @build_orders = BuildOrder.joins(build: [vehicle: :schedule_views])
      #                           .where(search_terms)
      #                           .where(buildorder_period(@search.date_from, @search.date_until))
      #                           .where(schedule_views: {id: params[:schedule_view_id]})
      #                           .select(build_order_fields)
      # New code:
      @build_orders = BuildOrder.includes(build: [vehicle: :schedule_views])
                                .where(search_terms)
                                .where(buildorder_period(@search.date_from, @search.date_until))
                                .where(schedule_views: {id: params[:schedule_view_id]})
    else
      # Old code:
      # @build_orders = BuildOrder.joins(build: [vehicle: :schedule_views])
      #                           .where(schedule_views: {id: params[:schedule_view_id]})
      #                           .select(build_order_fields)
      # New code:
      @build_orders = BuildOrder.includes(build: [vehicle: :schedule_views])
                                .where(schedule_views: {id: params[:schedule_view_id]})
    end
  end

  def off_hire_job_data
    puts "\nScheduleViewsController#off_hire_job_data"
    # Results, before change: Completed 200 OK in 452ms (Views: 280.5ms | ActiveRecord: 9.6ms)
    #                         Completed 200 OK in 466ms (Views: 435.8ms | ActiveRecord: 7.9ms)
    # Results, after change: Completed 200 OK in 257ms (Views: 220.0ms | ActiveRecord: 7.0ms)
    #                        Completed 200 OK in 358ms (Views: 321.6ms | ActiveRecord: 6.4ms)
    #                        Completed 200 OK in 371ms (Views: 242.6ms | ActiveRecord: 6.5ms)
    #                        Completed 200 OK in 355ms (Views: 313.9ms | ActiveRecord: 7.6ms)
    authorize! :view_off_hire_jobs, ScheduleView
    # Old code:
    # @off_hire_jobs = OffHireJob.joins(off_hire_report: [hire_agreement: [vehicle: :schedule_views]])
    #                            .where(schedule_views: {id: params[:schedule_view_id]})
    #                            .select('off_hire_jobs.id,
    #                              off_hire_jobs.service_provider_id,
    #                              off_hire_jobs.uid,
    #                              off_hire_jobs.name,
    #                              off_hire_jobs.off_hire_report_id,
    #                              off_hire_jobs.status,
    #                              off_hire_jobs.sched_time,
    #                              off_hire_jobs.etc'
    #                            )
    # New code:
    @off_hire_jobs = OffHireJob.includes(off_hire_report: [hire_agreement: [vehicle: :schedule_views]])
                               .where(schedule_views: {id: params[:schedule_view_id]})
  end

  def new
    @schedule_view = ScheduleView.new

    add_crumb "Schedule View"
    add_crumb "New"
  end

  def create
    @schedule_view = ScheduleView.new(schedule_view_params)
    if @schedule_view.save
      flash[:success] = "Schedule view was successfully created."
      redirect_to(:action => 'index')
    else
      render('new')
    end
  end

  def edit
    add_crumb @schedule_view.name, schedule_view_path(@schedule_view)
    add_crumb "Edit"
  end

  def update
    if @schedule_view.update_attributes(schedule_view_params)
      flash[:success] = "Schedule view updated."
      redirect_to(:action => 'index')
    else
      render('edit')
    end
  end

  def destroy
    @schedule_view.destroy
    flash[:success] = "#{@schedule_view.name} deleted."
    redirect_to(:action => 'index')
  end

  def destroy_vehicle
    if current_user.has_role? :masteradmin , :superadmin
      @schedule_views_data = VehicleScheduleView.find(params[:vehicle_view_id])
      @schedule_views_data.destroy
    end
  end

  private

    def hire_agreement_fields
      'hire_agreements.id, hire_agreements.customer_id, hire_agreements.uid, hire_agreements.vehicle_id, 
       hire_agreements.status, hire_agreements.pickup_time, hire_agreements.return_time'
    end

    def workorder_fields
      'workorders.id, workorders.service_provider_id, workorders.workorder_type_id, workorders.uid,
       workorders.vehicle_id, workorders.status, workorders.sched_time, workorders.etc'
    end

    def build_order_fields
      'build_orders.id, build_orders.service_provider_id, build_orders.uid, build_orders.name,
       build_orders.build_id, build_orders.status, build_orders.sched_time, build_orders.etc'
    end

    def hire_agreement_period(date_from, date_until)
      date_from_formatted = date_from.strftime('%Y-%m-%d')
      date_until_formatted = date_until.strftime('%Y-%m-%d')
      "hire_agreements.pickup_time <= #{date_until_formatted} OR hire_agreements.return_time >= #{date_from_formatted}"
    end

    def workorder_period(date_from, date_until)
      date_from_formatted = date_from.strftime('%Y-%m-%d')
      date_until_formatted = date_until.strftime('%Y-%m-%d')
      "workorders.sched_time >= '#{date_from_formatted}' AND workorders.sched_time <= '#{date_until_formatted}'"
    end

    def buildorder_period(date_from, date_until)
      date_from_formatted = date_from.strftime('%Y-%m-%d')
      date_until_formatted = date_until.strftime('%Y-%m-%d')
      "build_orders.sched_time >= '#{date_from_formatted}' AND build_orders.sched_time <= '#{date_until_formatted}'"
    end

    def formatted_search_terms
      return scope_all unless session[:search_params].present?
      @search = Search.new(session[:search_params])
      search_terms = []
      search_terms << "vehicles.rego_number like '%#{@search.rego}%'" if @search.rego
      search_terms << "vehicles.vin_number like '%#{@search.vin}%'" if @search.vin
      search_terms << "vehicles.call_sign like '%#{@search.call_sign}%'" if @search.call_sign
      search_terms << "vehicles.vehicle_number like '%#{@search.bus_num}%'" if @search.bus_num
      return scope_all unless search_terms.any?
      search_terms.join(" AND ")
    end

    def scope_all
      "vehicles.id > 0"
    end

    def set_schedule_view
      @schedule_view = ScheduleView.find(params[:id])
    end

    def search_params
      params.require(:search).permit(
          :view_type, :rego, :vin, :bus_num, :call_sign, :date_from, :date_until
        )
    end

    def schedule_view_params
      params.require(:schedule_view).permit(
        :name,
        :id,
        :vehicle_view_id,
        vehicle_schedule_views_attributes: [[
          :id,
          :vehicle_id,
          :schedule_view_id,
          :position,
          :_destroy
        ]]
      )
    end
end
