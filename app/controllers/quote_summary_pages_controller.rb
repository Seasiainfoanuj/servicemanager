class QuoteSummaryPagesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_quote_summary_page, only: [:edit, :update, :destroy]

  add_crumb("Quotes") { |instance| instance.send :quotes_path }

  def new
    if params[:quote_id]
      @quote = Quote.find_by_number(params[:quote_id])
      @quote_summary_page = QuoteSummaryPage.new(quote: @quote)

      add_crumb @quote.number, quote_path(@quote)
    else
      @quote_summary_page = QuoteSummaryPage.new
    end

    add_crumb 'Add Summary Page'
  end

  def create
    @quote_summary_page = QuoteSummaryPage.new(quote_summary_page_params)
    if @quote_summary_page.save
      flash[:success] = "Quote summary page created."
      redirect_to(:controller => 'quotes', :action => 'edit', :id => @quote_summary_page.quote.number.parameterize)
    else
      render 'new'
    end
  end

  def edit
    if params[:quote_id]
      add_crumb @quote.number, quote_path(@quote)
    end

    add_crumb 'Edit Summary Page'
  end

  def update
    if @quote_summary_page.update(quote_summary_page_params)
      flash[:success] = "Quote summary page updated."
      redirect_to(:controller => 'quotes', :action => 'edit', :id => @quote_summary_page.quote.number.parameterize)
    else
      render('edit')
    end
  end

  def destroy
    @quote_summary_page.destroy
    flash[:success] = "Quote summary page deleted."
    redirect_to edit_quote_path(@quote_summary_page.quote)
  end

  private
    def set_quote_summary_page
      @quote_summary_page = QuoteSummaryPage.find(params[:id])
      @quote = Quote.find_by_number!(params[:quote_id]) if params[:quote_id]
    end

    def quote_summary_page_params
      params.require(:quote_summary_page).permit(:quote_id, :text)
    end
end
