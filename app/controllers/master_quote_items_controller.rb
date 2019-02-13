class MasterQuoteItemsController < ApplicationController
  before_action :authenticate_user!
  authorize_resource

  before_action :set_master_quote_item, only: [:edit, :update, :destroy]

  add_crumb("Master Quote Items") { |instance| instance.send :master_quote_items_path }

  def index
    respond_to do |format|
      format.html
      format.json { render json: MasterQuoteItemsDatatable.new(view_context, current_user, params[:mode]) }
    end
  end

  def new
    @master_quote_item = MasterQuoteItem.new
    add_crumb 'New'
  end

  def create
    @master_quote_item = MasterQuoteItem.new(master_quote_item_params)
    @master_quote_item.primary_order = primary_sort_order(:create)
    if @master_quote_item.save
      flash[:success] = "Master quote item added."
      redirect_to(:action => 'index')
    else
      render('new')
    end
  end

  def edit
    add_crumb @master_quote_item.name, @master_quote_items
    add_crumb 'Edit'
  end

  def update
    @master_quote_item.primary_order = primary_sort_order(:update)
    if @master_quote_item.update(master_quote_item_params)
      flash[:success] = "Master quote item updated."
      redirect_to(:action => 'index')
    else
      render('edit')
    end
  end

  def destroy
    @master_quote_item.destroy
    flash[:success] = "Master quote item deleted."
    redirect_to(:action => 'index')
  end

private

  def primary_sort_order(action)
    if action == :create
      return 0 unless @master_quote_item.quote_item_type_id
      quote_item_type = QuoteItemType.find(@master_quote_item.quote_item_type_id)
      quote_item_type.sort_order
    else
      quote_item_type = QuoteItemType.find_by(id: master_quote_item_params['quote_item_type_id'])
      quote_item_type ? quote_item_type.sort_order : 0
    end
  end

  def set_master_quote_item
    @master_quote_item = MasterQuoteItem.find(params[:id])
  end

  def master_quote_item_params
    params.require(:master_quote_item).permit(
      :supplier_id,
      :service_provider_id,
      :name,
      :description,
      :quote_item_type_id,
      :cost,
      :cost_tax_id,
      :buy_price,
      :buy_price_tax_id,
      :quantity,
      :tag_list
    )
  end
end
