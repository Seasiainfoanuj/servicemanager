class MasterQuoteTypesController < ApplicationController
  before_action :authenticate_user!
  authorize_resource

  before_action :set_master_quote_type, only: [:edit, :update, :destroy]

  add_crumb("Master quote types") { |instance| instance.send :master_quote_types_path }

  def index
    @master_quote_types = MasterQuoteType.all
  end

  def new
    @master_quote_type = MasterQuoteType.new
    add_crumb 'New'
  end

  def create
    @master_quote_type = MasterQuoteType.new(master_quote_type_params)
    if @master_quote_type.save
      flash[:success] = "Master quote type added."
      redirect_to(:action => 'index')
    else
      render('new')
    end
  end

  def edit
    add_crumb @master_quote_type.name, @master_quote_types
    add_crumb 'Edit'
  end

  def update
    if @master_quote_type.update(master_quote_type_params)
      flash[:success] = "Master quote type updated."
      redirect_to(:action => 'index')
    else
      render('edit')
    end
  end

  def destroy
    @master_quote_type.destroy
    flash[:success] = "Master quote type deleted."
    redirect_to(:action => 'index')
  end

  private

    def set_master_quote_type
      @master_quote_type = MasterQuoteType.find(params[:id])
    end

    def master_quote_type_params
      params.require(:master_quote_type).permit(
        :name
      )
    end
end
