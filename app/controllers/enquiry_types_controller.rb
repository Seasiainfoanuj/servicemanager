class EnquiryTypesController < ApplicationController
  before_action :authenticate_user!
  authorize_resource

  before_action :set_enquiry_type, only: [:edit, :update, :destroy]

  add_crumb("Enquiry types") { |instance| instance.send :enquiry_types_path }

  def index
    @enquiry_types = EnquiryType.all
  end

  def new
    @enquiry_type = EnquiryType.new
    add_crumb 'New'
  end

  def create
    @enquiry_type = EnquiryType.new(enquiry_type_params)
    if @enquiry_type.save
      flash[:success] = "Enquiry type added."
      redirect_to(:action => 'index')
    else
      render('new')
    end
  end

  def edit
    add_crumb @enquiry_type.name, @enquiry_types
    add_crumb 'Edit'
  end

  def update
    if @enquiry_type.update(enquiry_type_params)
      flash[:success] = "Enquiry type updated."
      redirect_to(:action => 'index')
    else
      render('edit')
    end
  end

  def destroy
    @enquiry_type.destroy
    flash[:success] = "Enquiry type deleted."
    redirect_to(:action => 'index')
  end

  private

    def set_enquiry_type
      @enquiry_type = EnquiryType.find(params[:id])
    end

    def enquiry_type_params
      params.require(:enquiry_type).permit(
        :name, :slug
      )
    end
end
