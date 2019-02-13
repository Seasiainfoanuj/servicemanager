class QuoteItemTypesController < ApplicationController

  before_action :authenticate_user!
  authorize_resource
  
  before_action :set_quote_item_type, only: [:edit, :update, :destroy]

  add_crumb("Quote Item Types") { |instance| instance.send :quote_item_types_path }

  def index
    @quote_item_types = QuoteItemType.all
  end

  def new
    @quote_item_type = QuoteItemType.new
    add_crumb 'New'
  end

  def create
    @quote_item_type = QuoteItemType.new(quote_item_type_params)
    if @quote_item_type.save
      flash[:success] = "Quote Item Type created."
      redirect_to(action: 'index')
    else
      flash[:error] = "Quote Item Type could not be created."
      render 'new'
    end  
  end

  def edit
    add_crumb @quote_item_type.name, @quote_item_types
    add_crumb 'Edit'
  end

  def update
    if @quote_item_type.update(quote_item_type_params)
      flash[:success] = "Quote Item Type updated."
      redirect_to(action: 'index')
    else
      flash[:error] = "Quote Item Type could not be updated."
      render 'edit'
    end
  end

  def destroy
    @quote_item_type.destroy
    flash[:success] = "Quote Item Type deleted."
    redirect_to(action: 'index')
  end

  private

    def set_quote_item_type
      @quote_item_type = QuoteItemType.find(params[:id])
    end

    def quote_item_type_params
      params.require(:quote_item_type).permit(
        :name,
        :sort_order,
        :allow_many_per_quote,
        :taxable
      )
    end

end