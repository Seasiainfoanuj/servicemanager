class ContactRoleTypesController < ApplicationController

  before_action :authenticate_user!
  authorize_resource
  
  before_action :set_contact_role_type, only: [:edit, :update, :destroy]

  add_crumb("Contact Role Types") { |instance| instance.send :contact_role_types_path }

  def index
    @contact_role_types = ContactRoleType.all
  end

  def new
    @contact_role_type = ContactRoleType.new
    add_crumb 'New'
  end

  def create
    @contact_role_type = ContactRoleType.new(contact_role_type_params)
    if @contact_role_type.save
      flash[:success] = "Contact Role Type created."
      redirect_to(action: 'index')
    else
      flash[:error] = "Contact Role Type could not be created."
      render 'new'
    end  
  end

  def edit
    add_crumb @contact_role_type.name, @contact_role_types
    add_crumb 'Edit'
  end

  def update
    if @contact_role_type.update(contact_role_type_params)
      flash[:success] = "Contact Role Type updated."
      redirect_to(action: 'index')
    else
      flash[:error] = "Contact Role Type could not be updated."
      render 'edit'
    end
  end

  def destroy
    # Allow delete only if there are no associations
    # @contact_role_type.destroy
    # flash[:success] = "Contact Role Type deleted."
    # redirect_to(action: 'index')
  end

  private

    def set_contact_role_type
      @contact_role_type = ContactRoleType.find(params[:id])
    end

    def contact_role_type_params
      params.require(:contact_role_type).permit(
        :name
      )
    end

end