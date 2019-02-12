class VehicleModelsController < ApplicationController

  before_action :authenticate_user!
  authorize_resource
  
  before_action :set_vehicle_model, only: [:show, :edit, :update, :destroy,
      :add_hire_addon, :remove_hire_addon, :add_product_type, :remove_product_type]

  add_crumb("Vehicle Models") { |instance| instance.send :vehicle_models_path }

  def index
    session['last_request'] = '/vehicle_models'
    @vehicle_models = VehicleModel.all
  end

  def show
    add_crumb @vehicle_model.name
  end

  def new
    @vehicle_model = VehicleModel.new
    add_crumb 'New'
  end

  def create
    @vehicle_model = VehicleModel.new(vehicle_model_params)
    if @vehicle_model.save
      VehicleModelManager.new_vehicle_model_created(@vehicle_model)
      SearchTag.update_tag_list('vehicle_model', vehicle_model_params[:tags])
      flash[:success] = "Vehicle model added."
      redirect_to edit_vehicle_model_path(@vehicle_model)
    else
      flash[:error] = "Vehicle Model could not be created."
      render('new')
    end
  end

  def edit
    add_crumb "#{@vehicle_model.make.name} #{@vehicle_model.name}", @vehicle_models
    add_crumb 'Edit'
    @vehicle_model.images.build
    FeeType.includes(:standard_fee).each do |feetype|
      unless @vehicle_model.fees.map(&:fee_type_id).include?(feetype.id)
        amount = feetype.standard_fee ? feetype.standard_fee.fee_cents : 0
        @vehicle_model.fees.build(fee_type: feetype, fee_cents: amount)
      end
    end
  end

  def update
    if @vehicle_model.update(vehicle_model_params)
      SearchTag.update_tag_list('vehicle_model', vehicle_model_params[:tags])
      flash[:success] = "Vehicle model updated."
      redirect_to(action: 'show', id: @vehicle_model.id)
    else
      flash[:error] = "Vehicle Model could not be updated."
      render('edit')
    end
  end

  def destroy
    # @vehicle_model.destroy
    # flash[:success] = "Vehicle model deleted."
    # redirect_to(:action => 'index')
  end

  def add_hire_addon
    hire_addon_id = params.require(:hire_addon_id)
    hire_addon = HireAddon.find_by(id: hire_addon_id)
    @vehicle_model.hire_addons << hire_addon
    flash[:success] = "Hire Add-on #{hire_addon.name} has been added."
    render 'show'
  rescue => ex
    flash[:error] = "Hire Add-on #{hire_addon.name} has already been added." 
    render 'show'
  end

  def remove_hire_addon
    hire_addon_id = params.require(:hire_addon_id)
    hire_addon = HireAddon.find_by(id: hire_addon_id)
    @vehicle_model.hire_addons.delete(hire_addon)
    flash[:success] = "Hire Add-on #{hire_addon.name} has been removed."
    render 'show'
  rescue => ex
    flash[:error] = "Hire Add-on #{hire_addon.name} is not present in this collection." 
    render 'show'
  end

  def add_product_type
    product_type_id = params.require(:hire_product_type_id)
    product_type = HireProductType.find_by(id: product_type_id)
    @vehicle_model.hire_product_types << product_type
    flash[:success] = "Hire Product Type #{product_type.name} has been added."
    render 'show'
  rescue => ex
    flash[:error] = "Hire Product Type #{product_type.name} has already been added." 
    render 'show'
  end

  def remove_product_type
    product_type_id = params.require(:hire_product_type_id)
    product_type = HireProductType.find_by(id: product_type_id)
    @vehicle_model.hire_product_types.delete(product_type)
    flash[:success] = "Hire Product Type #{product_type.name} has been removed."
    render 'show'
  rescue => ex
    flash[:error] = "Hire Product Type #{product_type.name} is not present in this collection." 
    render 'show'
  end

  private

    def set_vehicle_model
      @vehicle_model = VehicleModel.find(params[:id])
    end

    def vehicle_model_params
      params.require(:vehicle_model).permit(
        :vehicle_make_id,
        :name,
        :number_of_seats,
        :daily_rate,
        :license_type,
        :tags,
        images_attributes: [:id, :document_type_id, :photo_category_id, 
          :imageable_id, :imageable_type, :image_type, :name, :image
        ],
        fees_attributes: [:id, :fee_type_id, :chargeable_id, :chargeable_type, 
                          :chargeable_unit, :fee, :_destroy]

    )
  end

end
