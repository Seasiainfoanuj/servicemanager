class BuildsController < ApplicationController

  before_action :authenticate_user!
  authorize_resource

  before_action :set_build, only: [:show, :edit, :update, :destroy]

  add_crumb("Builds") { |instance| instance.send :builds_path }

  def index
    @filtered_user = User.find(params[:filtered_user_id]) if params[:filtered_user_id]
    if @filtered_user
      add_crumb "Users", users_path
      add_crumb @filtered_user.name, user_path(@filtered_user)
      add_crumb('Builds') { |instance| instance.send :builds_path }
    end

    respond_to do |format|
      format.html
      format.json { render json: BuildsDatatable.new(view_context, current_user) }
    end
  end

  def show
    @activities = PublicActivity::Activity.order("created_at desc")
                                          .where(:trackable_type => "Build",
                                                 :trackable_id => @build.id)

    @build_orders = BuildOrder.order('sched_time ASC').where(build: @build)
    add_crumb @build.vehicle.ref_name, vehicle_path(@build.vehicle)
  end

  def build_orders
    @build = Build.find(params[:build_id])
    @build_orders = BuildOrder.order('sched_time ASC').where(build: @build)
  end

  def new
    @build = Build.new
    @build.number = Build.last.number.next if Build.last
    add_crumb "New"
  end

  def create
    @build = Build.new(build_params)
    if @build.save
      @build.create_activity :create, owner: current_user
      flash[:success] = "Build created."
      redirect_to(:action => 'show', :id => @build.id)
    else
      flash[:error] = "Build create was unsuccessful."
      render 'new'
    end
  end

  def edit
    add_crumb @build.number, @builds
    add_crumb 'Edit'
  end

  def update
    if @build.update(build_params)
      @build.create_activity :update, owner: current_user
      flash[:success] = "Build updated."
      redirect_to(:action => 'index')
    else
      flash[:error] = "Build update was unsuccessful."
      render('edit')
    end
  end

  def destroy
    @build.destroy
    flash[:success] = "Build deleted."
    redirect_to(:action => 'index')
  end

private

  def set_build
    @build = Build.find(params[:id])
  end

  def build_params
    params.require(:build).permit(
      :number,
      :vehicle_id,
      :manager_id,
      :quote_id,
      :invoice_company_id
    )
  end
end
