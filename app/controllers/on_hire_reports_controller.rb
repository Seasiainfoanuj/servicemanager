class OnHireReportsController < ApplicationController 
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_on_hire_report, only: [:show, :edit, :update, :destroy]

  # def index
  #   @on_hire_reports = OnHireReport.all
  # end

  def show
    @hire_agreement = @on_hire_report.hire_agreement
    add_crumb "Hire Agreements", hire_agreements_path
    add_crumb @hire_agreement.uid, hire_agreement_path(@hire_agreement)
    add_crumb "On Hire Report"
  end

  def new
    @hire_agreement = HireAgreement.find_by_uid!(params[:hire_agreement_id])
    @on_hire_report = OnHireReport.new(hire_agreement: @hire_agreement, user: current_user)

    @on_hire_report.report_time = Time.now unless @on_hire_report.report_time.present?

    if @on_hire_report.save
      redirect_to(:action => 'edit', :id => @on_hire_report.id)
    else
      flash[:error] = "There seemed to be a problem creating the on hire report."
      redirect_to hire_agreement_url(@hire_agreement)
    end
  end

  def edit
    @on_hire_report.report_time = Time.now unless @on_hire_report.report_time.present?
    
    @hire_agreement = @on_hire_report.hire_agreement

    add_crumb "Hire Agreements", hire_agreements_path
    add_crumb @hire_agreement.uid, hire_agreement_path(@hire_agreement)
    add_crumb "On Hire Report", hire_agreement_on_hire_report_url(@hire_agreement, @on_hire_report)
    add_crumb "Edit"
  end

  def create
    @on_hire_report = OnHireReport.new(on_hire_report_params)

    if @on_hire_report.save
      flash[:success] = "On hire report was successfully created."
      redirect_to(:action => 'edit', :id => @on_hire_report.id, :hire_agreement => @on_hire_report.hire_agreement)
    else
      render('new')
    end
  end

  def update
    if @on_hire_report.update(on_hire_report_params)
      if @on_hire_report.odometer_reading.present?
        unless @on_hire_report.hire_agreement.vehicle.odometer_reading.to_i >= @on_hire_report.odometer_reading.to_i
          @on_hire_report.hire_agreement.vehicle.odometer_reading = @on_hire_report.odometer_reading
          
          if @on_hire_report.hire_agreement.vehicle.save
            flash[:notice] = "Vehicle odometer has been updated."
          end
        end
      end

      @on_hire_report.hire_agreement.status = "on hire" unless @on_hire_report.hire_agreement.status == "returned" || @on_hire_report.hire_agreement.status == "cancelled"
      if @on_hire_report.hire_agreement.save
        flash[:alert] = "Hire agreement status updated to on hire."
      end

      flash[:success] = "On hire report was successfully updated."
      redirect_to(:action => 'show', :id => @on_hire_report.id, :hire_agreement_id => @on_hire_report.hire_agreement.uid)
    else
      render action: 'edit'
    end
  end

  def destroy
    @on_hire_report.destroy
    respond_to do |format|
      format.html { redirect_to on_hire_reports_url }
      format.json { head :no_content }
    end
  end

  private
    def set_on_hire_report
      @on_hire_report = OnHireReport.find(params[:id])
    end

    def on_hire_report_params
      params.require(:on_hire_report).permit(
        :hire_agreement_id,
        :user_id,
        :odometer_reading,
        :report_date_field,
        :report_time_field,
        :pickup_person_first_name,
        :pickup_person_last_name,
        :pickup_person_phone,
        :pickup_person_licence_number,
        :notes_exterior,
        :notes_interior,
        :notes_other,
        :spare_tyre_check,
        :tool_check,
        :wheel_nut_indicator_check,
        :triangle_stand_reflector_check,
        :first_aid_kit_check,
        :wheel_chock_check,
        :jump_start_lead_check,
        :fire_extinguisher_check,
        :mine_flag_check,
        :photo_check_front,
        :photo_check_rear,
        :photo_check_passenger_side,
        :photo_check_driver_side,
        :photo_check_fuel_gauge,
        :photo_check_rego_label,
        :photo_check_all_damages,
        :photo_check_windscreen,
        :fuel_check,
        :check_lights,
        :check_horn,
        :check_windscreen_washer_bottle,
        :check_wiper_blades,
        :check_service_sticker,
        :check_windscreen_chips,
        :check_vehicle_clean
      )
    end
end
