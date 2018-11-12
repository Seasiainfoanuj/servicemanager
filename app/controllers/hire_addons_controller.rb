class HireAddonsController < ApplicationController

  before_action :authenticate_user!
  authorize_resource
  
  before_action :set_hire_addon, only: [:show, :edit, :update, :destroy]

  add_crumb("Hire Add-ons") { |instance| instance.send :hire_addons_path }

  def index
    session['last_request'] = '/hire_addons'
    @hire_addons = HireAddon.all
  end

  def show
    add_crumb @hire_addon.name
  end

  def new
    @hire_addon = HireAddon.new
    add_crumb 'New'
  end

  def create
    @hire_addon = HireAddon.new(hire_addon_params)
    if @hire_addon.save
      flash[:success] = "Hire Add-on created."
      redirect_to(action: 'index')
    else
      flash[:error] = "Hire Add-on could not be created."
      render 'new'
    end  
  end

  def edit
    add_crumb @hire_addon.name, @hire_addons
    add_crumb 'Edit'
  end

  def update
    if @hire_addon.update(hire_addon_params)
      flash[:success] = "Hire Addon updated."
      redirect_to(action: 'index')
    else
      flash[:error] = "Hire Addon could not be updated."
      render 'edit'
    end
  end

  def destroy
    @hire_addon.destroy
    flash[:success] = "Hire Addon deleted."
    redirect_to(action: 'index')
  end

  private

    def set_hire_addon
      @hire_addon = HireAddon.find(params[:id])
    end

    def hire_addon_params
      params.require(:hire_addon).permit(
        :addon_type,
        :hire_model_name,
        :hire_price,
        :billing_frequency)
    end

end