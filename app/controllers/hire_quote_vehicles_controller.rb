class HireQuoteVehiclesController < ApplicationController

  before_action :authenticate_user!
  authorize_resource
  
  before_action :set_hire_quote, only: [:show, :edit, :update, :new, :create, :destroy, :add_addon, :remove_addon]
  before_action :set_hire_quote_vehicle, only: [:show, :edit, :update, :destroy, :add_addon, :remove_addon]

  add_crumb("Hire Quotes")

  def new
    return unless action_is_authorised?(:add_quote_vehicle)
    if @hire_quote.enquiry && @hire_quote.vehicles.none?
      fill_vehicle_details_from_enquiry
      flash[:success] = "Hire Quote #{@hire_quote.reference} has been created from enquiry #{@hire_quote.enquiry.uid}. Choose a Hire Product and fill in the missing details."
    else
      @hire_quote_vehicle = HireQuoteVehicle.new(hire_quote_id: @hire_quote.id)
    end
    add_crumb(@hire_quote.reference)
    add_crumb("Quoted Vehicles")
    add_crumb 'New'
  end

  def show
    add_crumb(@hire_quote_vehicle.hire_quote.reference, hire_quote_path(@hire_quote_vehicle.hire_quote.reference))
    add_crumb("Quoted Vehicles")
    add_crumb(@hire_quote_vehicle.vehicle_model.name)
  end

  def create
    @hire_quote_vehicle = HireQuoteVehicle.new(hire_quote_vehicle_params)
    @hire_quote_vehicle.hire_quote_id = @hire_quote.id
    if @hire_quote_vehicle.save
      @hire_quote_vehicle.vehicle_model.fees.each do |fee|
        @hire_quote_vehicle.fees.build(fee_type: fee.fee_type, fee_cents: fee.fee_cents)
      end
      if @hire_quote_vehicle.save
        @hire_quote.create_activity :vehicle_added, owner: current_user, parameters: {vehicle_model_name: @hire_quote_vehicle.vehicle_model.name}
        flash[:success] = "Vehicle added to Hire Quote and default fees have been created. You may now change the fees if necessary."
        redirect_to edit_hire_quote_hire_quote_vehicle_path(@hire_quote_vehicle.hire_quote, @hire_quote_vehicle)
      else
        flash[:error] = "The vehicle has been added to the Hire Quote, but the default fees could not be added. Please contact Support." 
      end
    else
      flash[:error] = "Hire Quote Vehicle could not be created." 
      render 'new'
    end  
  end

  def edit
    return unless action_is_authorised?(:update_quote_vehicle)
    add_crumb(@hire_quote_vehicle.hire_quote.reference, hire_quote_path(@hire_quote_vehicle.hire_quote.reference))
    add_crumb("Quoted Vehicles")
    add_crumb(@hire_quote_vehicle.vehicle_model.name)
    add_crumb 'edit'

    @hire_quote_vehicle.vehicle_model.fees.each do |hirefee|
      unless @hire_quote_vehicle.fees.map(&:fee_type_id).include?(hirefee.fee_type_id)
        @hire_quote_vehicle.fees.build(fee_type: hirefee.fee_type, fee_cents: hirefee.fee_cents)
      end
    end
  end

  def update
    if @hire_quote_vehicle.update(hire_quote_vehicle_params)
      @hire_quote.create_activity :vehicle_updated, owner: current_user, parameters: {vehicle_model_name: @hire_quote_vehicle.vehicle_model.name}
      flash[:success] = "Hire Quote Vehicle updated."
      redirect_to hire_quote_hire_quote_vehicle_path(@hire_quote_vehicle.hire_quote, @hire_quote_vehicle)
    else
      flash[:error] = "Hire Quote Vehicle could not be updated." 
      render 'edit'
    end 
  end

  def destroy
    return unless action_is_authorised?(:delete_quote_vehicle)
    @hire_quote_vehicle.destroy
    @hire_quote.create_activity :vehicle_removed, owner: current_user, parameters: {vehicle_model_name: @hire_quote_vehicle.vehicle_model.name}
    flash[:success] = "Vehicle has been removed from quote."
    redirect_to hire_quote_path(@hire_quote_vehicle.hire_quote)
  end

  def add_addon
    return unless action_is_authorised?(:add_hire_addon)
    hire_addon_id = params.require(:hire_addon_id).to_i
    hire_addon = HireAddon.find_by(id: hire_addon_id)
    existing_addon_ids = @hire_quote_vehicle.addons.map(&:hire_addon_id)
    if existing_addon_ids.include?(hire_addon_id)
      flash[:error] = "Hire Add-on #{hire_addon.name} has already been added"
      redirect_to hire_quote_hire_quote_vehicle_path(@hire_quote_vehicle.hire_quote, @hire_quote_vehicle)
      return
    end
    @hire_quote_vehicle.addons.build(hire_addon: hire_addon, hire_price_cents: hire_addon.hire_price_cents)
    if @hire_quote_vehicle.save
      @hire_quote.create_activity :addon_added, owner: current_user, parameters: {addon_name: hire_addon.name, vehicle_model_name: @hire_quote_vehicle.vehicle_model.name}
      flash[:success] = "Hire Add-on #{hire_addon.name} has been added."
    else
      flash[:error] = "Hire Add-on #{hire_addon.name} could not be added"
    end
    redirect_to hire_quote_hire_quote_vehicle_path(@hire_quote_vehicle.hire_quote, @hire_quote_vehicle)
  end

  def remove_addon
    return unless action_is_authorised?(:delete_hire_addon)
    hire_quote_addon_id = params.require(:hire_quote_addon_id)
    hire_quote_addon = HireQuoteAddon.find_by(id: hire_quote_addon_id)
    hire_addon_name = hire_quote_addon.hire_addon.name
    hire_quote_addon.destroy
    @hire_quote.create_activity :addon_removed, owner: current_user, parameters: {addon_name: hire_addon_name, vehicle_model_name: @hire_quote_vehicle.vehicle_model.name}
    flash[:success] = "Hire Add-on #{hire_addon_name} has been removed."
    redirect_to hire_quote_hire_quote_vehicle_path(@hire_quote_vehicle.hire_quote, @hire_quote_vehicle)
  rescue => ex
    flash[:error] = "Hire Add-on #{hire_addon_name} is not present in this collection." 
    render 'show'
  end

  private

    def set_hire_quote
      hire_quote_params = params.permit(:hire_quote_id)
      @hire_quote = HireQuote.find_by(reference: hire_quote_params[:hire_quote_id])
    end

    def set_hire_quote_vehicle
      @hire_quote_vehicle = HireQuoteVehicle.find_by(id: params[:id])
    end

    def hire_quote_vehicle_params
      params.require(:hire_quote_vehicle).permit(
        :hire_quote_id,
        :vehicle_model_id,
        :start_date_field,
        :end_date_field,
        :ongoing_contract,
        :delivery_required,
        :demobilisation_required,
        :pickup_location,
        :dropoff_location,
        :delivery_location,
        :daily_rate,
        fees_attributes: [:id, :fee_type_id, :chargeable_id, :chargeable_type, :chargeable_unit, :fee],
        addons_attributes: [:id, :hire_addon_id, :hire_price]
        )
    end

    def fill_vehicle_details_from_enquiry
      enquiry = @hire_quote.enquiry
      return unless enquiry && enquiry.hire_enquiry
      @hire_quote_vehicle = HireQuoteVehicle.new(
        hire_quote_id: @hire_quote.id,
        start_date: enquiry.hire_enquiry.hire_start_date,
        end_date: enquiry.hire_enquiry.end_date,
        ongoing_contract: enquiry.hire_enquiry.ongoing_contract,
        delivery_required: enquiry.hire_enquiry.delivery_required,
        delivery_location: enquiry.hire_enquiry.delivery_location)
    end

    def action_is_authorised?(action)
      if @hire_quote.admin_may_perform_action?(action)
        true 
      else
        flash[:error] = "Unauthorised action"
        redirect_to :back
        false
      end
    end

end  