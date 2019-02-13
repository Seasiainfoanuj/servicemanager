class SavedQuoteItemsController < ApplicationController

  before_action :authenticate_user!
  authorize_resource
  
  before_action :set_saved_quote_item, only: [:edit, :update, :destroy]

  add_crumb("Saved Quote Items") { |instance| instance.send :saved_quote_items_path }

  def index
    # @saved_quote_items = SavedQuoteItem.all
    respond_to do |format|
      format.html
      format.json { render json: SavedQuoteItemsDatatable.new(view_context, current_user, params[:mode]) }
    end
  end

  def new
    @saved_quote_item = SavedQuoteItem.new
    add_crumb 'New'
  end

  def create
    @saved_quote_item = SavedQuoteItem.new(saved_quote_item_params)
    if @saved_quote_item.save
      flash[:success] = "Saved quote item added."
      redirect_to(:action => 'index')
    else
      render('new')
    end
  end

  def edit
    add_crumb @saved_quote_item.name, @saved_quote_items
    add_crumb 'Edit'
  end

  def update
    if @saved_quote_item.update(saved_quote_item_params)
      flash[:success] = "Saved quote item updated."
      redirect_to(:action => 'index')
    else
      render('edit')
    end
  end

  def destroy
    @saved_quote_item.destroy
    flash[:success] = "Saved quote item deleted."
    redirect_to(:action => 'index')
  end

private

  def set_saved_quote_item
    @saved_quote_item = SavedQuoteItem.find(params[:id])
  end

  def saved_quote_item_params
    params.require(:saved_quote_item).permit(
      :tax_id,
      :name,
      :description,
      :cost,
      :quantity
    )
  end

end
