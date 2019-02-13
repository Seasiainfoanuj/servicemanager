class ScheduleController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize! :view, :schedule
    @workorders = Workorder.all
    #@workorders = Workorder.where.not(:status => "cancelled").where.not(:status => "complete")
  end

  def vehicles
    if current_user.has_role? :admin
      @vehicles = Vehicle.where(:exclude_from_schedule => [nil, false]).sort! { |a,b| a.number_int <=> b.number_int }
    else
      status = %w[complete cancelled]

      builds_vehicles = Build.where(id: BuildOrder.where(service_provider_id: current_user).where.not(status: status)).pluck(:vehicle_id)
      hire_agreement_vehicles = HireAgreement.where.not(status: status).where(id: OffHireReport.where(id:
                                OffHireJob.where.not(status: status).where(service_provider: current_user))).pluck(:vehicle_id)
      workorder_vehicles = Workorder.where(service_provider: current_user).where.not(status: status).pluck(:vehicle_id)

      vehicle_ids = (builds_vehicles + hire_agreement_vehicles + workorder_vehicles).uniq
      @vehicles = Vehicle.where(id: vehicle_ids)
                  .where(:exclude_from_schedule => [nil, false]).sort! { |a,b| a.number_int <=> b.number_int }
    end
  end

  def hire_agreement_data
     if current_user.has_role? :admin
      @hire_agreements = HireAgreement.order('created_at DESC')

      if params[:vehicle_id]
        @hire_agreements = @hire_agreements.where(vehicle_id: params[:vehicle_id])
      end
    else
      @hire_agreements = []
     end
  end

  def workorder_data
     if current_user.has_role? :admin
      @workorders = Workorder.order('created_at DESC')
    else
      @workorders = Workorder.where(service_provider_id: current_user.id)
     end

    if params[:vehicle_id]
      @workorders = @workorders.where(vehicle_id: params[:vehicle_id])
    end
  end

  def build_order_data
    if current_user.has_role? :admin
      @build_orders = BuildOrder.order('created_at DESC')
    else
      @build_orders = BuildOrder.where(service_provider_id: current_user.id)
    end

    if params[:vehicle_id]
      @build_orders = @build_orders.joins(:build).where("builds.vehicle_id = ?", params[:vehicle_id])
    end
  end

  def off_hire_job_data
    if current_user.has_role? :admin
      @off_hire_jobs = OffHireJob.order('created_at ASC')
    else
      @off_hire_jobs = OffHireJob.where(service_provider_id: current_user.id)
    end

    if params[:vehicle_id]
      @off_hire_jobs = @off_hire_jobs.joins(off_hire_report: [:hire_agreement]).where("hire_agreements.vehicle_id = ?", params[:vehicle_id])
    end
  end
end
