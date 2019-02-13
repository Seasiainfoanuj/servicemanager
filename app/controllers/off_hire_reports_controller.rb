class OffHireReportsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_off_hire_report, only: [:show, :edit, :update, :destroy]

  # def index
  #   @off_hire_reports = OffHireReport.all
  # end

  def show
    @hire_agreement = @off_hire_report.hire_agreement
    add_crumb "Hire Agreements", hire_agreements_path
    add_crumb @hire_agreement.uid, hire_agreement_path(@hire_agreement)
    add_crumb "Off Hire Report"
  end

  def off_hire_jobs
    @off_hire_report = OffHireReport.find(params[:off_hire_report_id])
    @off_hire_jobs = OffHireJob.order('sched_time ASC').where(off_hire_report: @off_hire_report)
  end

  def new
    @hire_agreement = HireAgreement.find_by_uid!(params[:hire_agreement_id])
    @off_hire_report = OffHireReport.new(hire_agreement: @hire_agreement, user: current_user)

    @off_hire_report.report_time = Time.now unless @off_hire_report.report_time.present?

    if @off_hire_report.save
      redirect_to(:action => 'edit', :id => @off_hire_report.id)
    else
      flash[:error] = "There seemed to be a problem creating the off hire report."
      redirect_to hire_agreement_url(@hire_agreement)
    end
  end

  def edit
    @off_hire_report.report_time = Time.now unless @off_hire_report.report_time.present?

    @hire_agreement = @off_hire_report.hire_agreement

    add_crumb "Hire Agreements", hire_agreements_path
    add_crumb @hire_agreement.uid, hire_agreement_path(@hire_agreement)
    add_crumb "Off Hire Report", hire_agreement_off_hire_report_url(@hire_agreement, @off_hire_report)
    add_crumb "Edit"
  end

  def create
    @off_hire_report = OffHireReport.new(off_hire_report_params)

    if @off_hire_report.save
      flash[:success] = "Off hire report was successfully created."
      redirect_to(:action => 'edit', :id => @off_hire_report.id, :hire_agreement => @off_hire_report.hire_agreement)
    else
      render('new')
    end
  end

  def update
    if @off_hire_report.update(off_hire_report_params)
      if @off_hire_report.odometer_reading.present?
        unless @off_hire_report.hire_agreement.vehicle.odometer_reading.to_i >= @off_hire_report.odometer_reading.to_i
          @off_hire_report.hire_agreement.vehicle.odometer_reading = @off_hire_report.odometer_reading

          if @off_hire_report.hire_agreement.vehicle.save
            flash[:notice] = "Vehicle odometer has been updated."
          end
        end
      end

      @off_hire_report.hire_agreement.status = "returned" unless @off_hire_report.hire_agreement.status == "cancelled"
      if @off_hire_report.hire_agreement.save
        flash[:alert] = "Hire agreement status updated to returned."
      end

      flash[:success] = "Off hire report was successfully updated."
      redirect_to(:action => 'show', :id => @off_hire_report.id, :hire_agreement_id => @off_hire_report.hire_agreement.uid)
    else
      render action: 'edit'
    end
  end

  def destroy
    @off_hire_report.destroy
  end

  private
    def set_off_hire_report
      @off_hire_report = OffHireReport.find(params[:id])
    end

    def off_hire_report_params
      params.require(:off_hire_report).permit(
        :hire_agreement_id,
        :user_id,
        :odometer_reading,
        :report_date_field,
        :report_time_field,
        :dropoff_person_first_name,
        :dropoff_person_last_name,
        :dropoff_person_phone,
        :dropoff_person_licence_number,
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
        :fuel_litres,
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
