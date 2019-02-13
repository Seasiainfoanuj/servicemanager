class WorkorderTypesController < ApplicationController

  before_action :authenticate_user!
  authorize_resource
  
  before_action :set_workorder_type, only: [:edit, :update, :destroy]

  add_crumb("Workorder Types") { |instance| instance.send :workorder_types_path }

  def index
    @workorder_types = WorkorderType.all
  end

  def new
    @workorder_type = WorkorderType.new
    add_crumb 'New'
  end

  def create
    @workorder_type = WorkorderType.new(workorder_type_params)
    if @workorder_type.save
      flash[:success] = "Workorder type added."
      redirect_to(:action => 'index')
    else
      render('new')
    end
  end

  def edit
    add_crumb @workorder_type.name, @workorder_types
    add_crumb 'Edit'
  end

  def update
    if @workorder_type.update(workorder_type_params)
      flash[:success] = "Workorder type updated."
      redirect_to(:action => 'index')
    else
      render('edit')
    end
  end

  def destroy
    @workorder_type.destroy
    flash[:success] = "Workorder type deleted."
    redirect_to(:action => 'index')
  end

private

  def set_workorder_type
    @workorder_type = WorkorderType.find(params[:id])
  end

  def workorder_type_params
    params.require(:workorder_type).permit(
      :name,
      :label_color,
      :notes
    )
  end

end
