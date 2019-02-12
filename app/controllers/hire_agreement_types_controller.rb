class HireAgreementTypesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  
  before_action :set_hire_agreement_type, only: [:edit, :update, :destroy]

  add_crumb("Hire Agreement Types") { |instance| instance.send :hire_agreement_types_path }

  def index
    @hire_agreement_types = HireAgreementType.all
  end

  def new
    @hire_agreement_type = HireAgreementType.new
    add_crumb 'New'
  end

  def create
    @hire_agreement_type = HireAgreementType.new(hire_agreement_type_params)
    if @hire_agreement_type.save
      flash[:success] = "Hire agreement type added."
      redirect_to(:action => 'edit', :id => @hire_agreement_type.id)
    else
      render('new')
    end
  end

  def edit
    add_crumb @hire_agreement_type.name, @hire_agreement_types
    add_crumb 'Edit'
  end

  def update
    if @hire_agreement_type.update(hire_agreement_type_params)
      flash[:success] = "Hire agreement type updated."
      redirect_to(:action => 'index')
    else
      render('edit')
    end
  end

  def destroy
    unless @hire_agreement_type.hire_agreements.count > 0
      @hire_agreement_type.destroy
      flash[:success] = "Hire agreement type deleted."
      redirect_to(:action => 'index')
    else
      flash[:error] = "#{@hire_agreement_type.name} cannot be deleted because it has hire agreements."
      redirect_to(:action => 'index')
    end
  end

private

  def set_hire_agreement_type
    @hire_agreement_type = HireAgreementType.find(params[:id])
  end

  def hire_agreement_type_params
    params.require(:hire_agreement_type).permit(
      :name,
      :damage_recovery_fee,
      :fuel_service_fee
    )
  end
end
