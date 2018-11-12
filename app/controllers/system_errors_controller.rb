class SystemErrorsController < ApplicationController

  before_filter :authenticate_user!

  before_action :set_system_error, only: [:show, :edit, :update, :destroy]

  add_crumb "System Error"

  def log
    authorize! :view, :system_error_log
    if params['scope'] == 'all'
      @error_log = SystemError.all
    else
      @error_log = SystemError.unsolved
    end
    add_crumb 'Log'
  end

  def unresolved_log
    authorize! :view, :system_error_log
    if params['scope'] == 'all'
      @error_log = SystemError.all
    else
      @error_log = SystemError.unsolved
    end

  end

  def show
    redirect_to :back if @system_error.nil? 
    add_crumb 'Details'
    add_crumb @system_error.id
  end

  def edit
    add_crumb 'Edit'
    add_crumb @system_error.id
  end


  def destroy
   @system_error.destroy
    flash[:success] = "System error deleted."
    redirect_to(:action => 'log')
  end

  def update
    if params["action_taken"] == "Yes"
      if @system_error.error_status == SystemError::ACTION_REQUIRED
        @system_error.error_status = SystemError::ACTIONED_BY_BUSINESS
      elsif @system_error.error_status == SystemError::ACTIONED_BY_BUSINESS
        @system_error.error_status = SystemError::SOLUTION_IMPLEMENTED
      end
      @system_error.actioned_by = current_user
      @system_error.save!
    end
    render :show
  end
  
 
  private

    def set_system_error
      @system_error = SystemError.find_by(id: params[:id])
    end

    def system_error_params_formatted
      new_params = system_error_params
      new_params['resource_type'] = new_params['resource_type'].to_i
      new_params['error_status'] = new_params['error_status'].to_i
    end

    def system_error_params
      params.require(:system_error).permit(
        :resource_type,
        :error_status)
    end  
end