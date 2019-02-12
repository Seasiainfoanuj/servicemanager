class BuildSpecificationsController < ApplicationController

  before_action :authenticate_user!
  authorize_resource

  before_action :set_build
  before_action :set_build_specification, only: [:show, :edit, :update, :destroy, :complete]

  add_crumb("Builds")

  def new
    if @build.specification.present?
      redirect_to(:action => 'edit')
      return
    end
    add_crumb(@build.number)
    add_crumb("Build Specification")
    add_crumb("New")
    @build_specification = BuildSpecification.new
  end

  def edit
    add_crumb(@build.number)
    add_crumb("Build Specification")
    add_crumb("Edit")
  end

  def show
    @activities = PublicActivity::Activity.order("created_at desc")
                                          .where(:trackable_type => "BuildSpecification",
                                                 :trackable_id => @build_specification.id)
    add_crumb(@build.number)
    add_crumb 'Build Specification details'
    set_spec_presenter
  end

  def full_spec_sheet
  end

  def create
    @build_specification = BuildSpecification.new(build_specification_params)
    if @build_specification.save
      @build_specification.create_activity :create, owner: current_user
      flash[:success] = "Build specification created."
      redirect_to(:action => 'show', :build_id => params[:build_id])
    else
      flash[:error] = "Build specification create was unsuccessful."
      render :new
    end
  end

  def update
    if @build_specification.update_attributes(build_specification_params)
      @build_specification.create_activity :update, owner: current_user
      flash[:success] = "Build specification updated."
      redirect_to(:action => 'show', :build_id => @build_specification.build.id)
    else
      flash[:error] = "Build specification update was unsuccessful."
      render :edit
    end
  end

  def complete
    set_spec_presenter
    respond_to do |format|
      format.html do
        add_crumb(@build.number)
        add_crumb 'Build Specification details'
      end
      format.pdf do
        pdf = BuildSpecificationPdf.new(@spec_presenter, view_context)
        send_data pdf.render, filename: "build-specification-#{@build.number}.pdf",
                              type: "application/pdf",
                              disposition: "inline"                           
      end
    end
  end

  private

    def build_specification_params
      params.require(:build_specification).permit(
        :build_id, :swing_type, :paint, :heating_source, :total_seat_count,
        :seating_type, :other_seating, :state_sign, :surveillance_system, :lift_up_wheel_arches, 
        :comments
        )
    end

    def set_spec_presenter
      @spec_presenter = BuildSpecificationPresenter.new(@build_specification)
    end

    def set_build
      if params[:build_id].empty?
        flash[:alert] = "Build is missing"
        redirect_to request.referer and return
      end
      @build = Build.find(params[:build_id])
    end

    def set_build_specification
      @build_specification = @build.specification
    end
end
