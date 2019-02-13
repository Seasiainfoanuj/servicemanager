class FeeTypesController < ApplicationController

  before_action :authenticate_user!
  authorize_resource
  
  before_action :set_fee_type, only: [:edit, :update, :destroy]

  add_crumb("Fee Types") { |instance| instance.send :fee_types_path }

  def index
    @fee_types = FeeType.includes(:standard_fee)
  end

  def new
    @fee_type = FeeType.new
    @fee_type.build_standard_fee(fee_type: @fee_type)
    add_crumb 'New'
  end

  def create
    @fee_type = FeeType.new(fee_type_params)
    if @fee_type.save
      if fee_type_params[:standard_fee_attributes].present? && 
           fee_type_params[:standard_fee_attributes][:fee].present?
        fee = fee_type_params[:standard_fee_attributes][:fee]
        @fee_type.build_standard_fee(chargeable: @fee_type, fee_type: @fee_type, fee: fee) 
        @fee_type.save!
      end 
      flash[:success] = "Fee Type created."
      redirect_to(action: 'index')
    else
      flash[:error] = "Fee Type could not be created."
      render 'new'
    end  
  end

  def edit
    add_crumb @fee_type.name, @fee_types
    @fee_type.build_standard_fee(fee_type_id: @fee_type.id) unless @fee_type.standard_fee.present?
    add_crumb 'Edit'
  end

  def update
    if @fee_type.update(fee_type_params)
      flash[:success] = "Fee Type updated."
      redirect_to(action: 'index')
    else
      flash[:error] = "Fee Type could not be updated."
      render 'edit'
    end
  end

  def destroy
    @fee_type.destroy
    flash[:success] = "Fee Type deleted."
    redirect_to(action: 'index')
  end

  private

    def set_fee_type
      @fee_type = FeeType.find(params[:id])
    end

    def fee_type_params
      params.require(:fee_type).permit(
        :name, 
        :category,
        :charge_unit,
        standard_fee_attributes: [:id, :fee_type_id, :chargeable_id, :chargeable_type, :chargeable_unit, :fee] )
    end

end