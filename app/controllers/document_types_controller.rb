class DocumentTypesController < ApplicationController

  before_action :authenticate_user!
  authorize_resource
  
  before_action :set_document_type, only: [:edit, :update, :destroy]

  add_crumb("Document Types") { |instance| instance.send :document_types_path }

  def index
    @document_types = DocumentType.all
  end

  def new
    @document_type = DocumentType.new
    add_crumb 'New'
  end

  def create
    @document_type = DocumentType.new(document_type_params)
    if @document_type.save
      flash[:success] = "Document type added."
      redirect_to(action: 'index')
    else
      error_msg = ""
      @document_type.errors.full_messages.each { |e| error_msg << "#{e}. " }
      flash[:error] = "#{error_msg}"
      render 'new'
    end  
  end

  def edit
    add_crumb @document_type.name, @document_types
    add_crumb 'Edit'
  end

  def update
    if @document_type.update(document_type_params)
      flash[:success] = "Document type updated."
      redirect_to(action: 'index')
    else
      error_msg = ""
      @document_type.errors.full_messages.each { |e| error_msg << "#{e}. " }
      flash[:error] = "#{error_msg}"
      render 'edit'
    end
  end

  def destroy
    @document_type.destroy
    flash[:success] = "Document type deleted."
    redirect_to(action: 'index')
  end

  private

    def set_document_type
      @document_type = DocumentType.find(params[:id])
    end

    def document_type_params
      params.require(:document_type).permit(
        :name,
        :label_color
      )
    end

end