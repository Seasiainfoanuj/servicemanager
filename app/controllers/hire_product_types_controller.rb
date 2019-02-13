class HireProductTypesController < ApplicationController

  before_action :authenticate_user!
  authorize_resource
  
  before_action :set_hire_product_type, only: [:edit, :update, :destroy]

  add_crumb("Hire Product Types") { |instance| instance.send :hire_product_types_path }

  def index
    @hire_product_types = HireProductType.all
  end

  def new
    @hire_product_type = HireProductType.new
    add_crumb 'New'
  end

  def create
    @hire_product_type = HireProductType.new(hire_product_type_params)
    if @hire_product_type.save
      flash[:success] = "Hire Product Type created."
      redirect_to(action: 'index')
    else
      flash[:error] = "Hire Product Type could not be created."
      render 'new'
    end  
  end

  def edit
    add_crumb @hire_product_type.name, @hire_product_types
    add_crumb 'Edit'
  end

  def update
    if @hire_product_type.update(hire_product_type_params)
      flash[:success] = "Hire Product Type updated."
      redirect_to(action: 'index')
    else
      flash[:error] = "Hire Product Type could not be updated."
      render 'edit'
    end
  end

  def destroy
    # Allow delete only if there are no associations
    # @hire_product_type.destroy
    # flash[:success] = "Hire Product Type deleted."
    # redirect_to(action: 'index')
  end

  private

    def set_hire_product_type
      @hire_product_type = HireProductType.find(params[:id])
    end

    def hire_product_type_params
      params.require(:hire_product_type).permit(
        :name
      )
    end

end