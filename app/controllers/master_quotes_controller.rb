class MasterQuotesController < ApplicationController
  layout :resolve_layout

  before_action :authenticate_user!
  authorize_resource

  before_action :set_master_quote, only: [:show, :edit, :update, :destroy]

  add_crumb("Master Quotes") { |instance| instance.send :master_quotes_path }

  def index
    respond_to do |format|
      format.html
      format.json { render json: MasterQuotesDatatable.new(view_context, current_user) }
    end
  end

  def show
    @current_customer = get_current_customer
    @activities = PublicActivity::Activity.order("created_at desc")
                                          .where(:trackable_type => "MasterQuote",
                                                 :trackable_id => @master_quote.id)
    add_crumb @master_quote.name
  end

  def new
    @master_quote = MasterQuote.new
    @master_quote_items = MasterQuoteItem.order("name ASC").paginate(:page => params[:page], :per_page => 5)

    3.times { @master_quote.items.build }
    add_crumb "New"
  end

  def create
    @master_quote = MasterQuote.new(master_quote_params_modified)
    if @master_quote.save
      @master_quote.create_activity :create, owner: current_user
      flash[:success] = "Master quote created."
      redirect_to(:action => 'show', :id => @master_quote.id)
    else
      render 'new'
    end
  end

  def duplicate
    authorize! :duplicate, MasterQuote
    @old_quote = MasterQuote.find(params[:master_quote_id])

    @master_quote = @old_quote.dup
    @master_quote.name = "#{@old_quote.name} - Copy"

    @old_quote.items.each do |item|
      dup_item = item.clone
      dup_item.master_quotes << @master_quote
      @master_quote.items << dup_item
    end

    if @master_quote.save
      if @old_quote.title_page
        @master_quote.create_title_page(
          title: @old_quote.title_page.title,
          image_1: @old_quote.title_page.image_1,
          image_2: @old_quote.title_page.image_2
        )
      end

      if @old_quote.summary_page
        @master_quote.create_summary_page(
          text: @old_quote.summary_page.text
        )
      end

      @master_quote.create_activity :duplicate, owner: current_user
      flash[:notice] = "Master quote #{@old_quote.name} duplicated."
      redirect_to edit_master_quote_path(@master_quote)
    else
      flash[:error] = "There was a problem duplicating #{@old_quote.name}."
      redirect_to @old_quote
    end
  end

  def edit
    add_crumb @master_quote.name, master_quote_path(@master_quote)
    add_crumb 'Edit'
  end

  def update
    if @master_quote.update(master_quote_params_modified)
      @master_quote.create_activity :update, owner: current_user
      flash[:success] = "Master quote updated."
      redirect_to(:action => 'show')
    else
      render('edit')
    end
  end

  def destroy
    @master_quote.destroy
    flash[:success] = "Master quote deleted."
    redirect_to(:action => 'index')
  end

private

  def resolve_layout
    case action_name
    when "show"
      "clean"
    else
      "application"
    end
  end

  def set_master_quote
    @master_quote = MasterQuote.find(params[:id])
  end

  def get_current_customer
    enquiry_id = session['current_enquiry']
    return nil unless enquiry_id.present?
    enquiry = Enquiry.find_by(id: enquiry_id)
    enquiry.present? ? enquiry.user_id : nil
  end

  def master_quote_params_modified
    temp_params = new_params = master_quote_params
    @sort_order_rules = {}
    QuoteItemType.all.map { |type| @sort_order_rules[type.id.to_s] = type.sort_order }
    if new_params['items_attributes'].present?
      temp_params['items_attributes'].each do |item|
        if new_params['items_attributes'][item.first]['quote_item_type_id']
          quote_item_type_id = new_params['items_attributes'][item.first]['quote_item_type_id']
          sort_order = @sort_order_rules[quote_item_type_id]
          new_params['items_attributes'][item.first]['primary_order'] = sort_order.to_i
        end
      end  
    end
    new_params
  end

  def master_quote_params
    params.require(:master_quote).permit(
      :master_quote_type_id,
      :vehicle_make,
      :vehicle_model,
      :transmission_type,
      :name,
      :terms,
      :notes,
      :seating_number,
      items_attributes: [
        :id,
        :supplier_id,
        :service_provider_id,
        :master_quote_id,
        :name,
        :description,
        :quote_item_type_id,
        :cost,
        :cost_tax_id,
        :buy_price,
        :buy_price_tax_id,
        :quantity,
        :position,
        :_destroy
      ]
    )
  end
end
