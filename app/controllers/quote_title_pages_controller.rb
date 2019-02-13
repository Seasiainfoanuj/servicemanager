class QuoteTitlePagesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_quote_title_page, only: [:edit, :update, :destroy]

  add_crumb("Quotes") { |instance| instance.send :quotes_path }

  def new
    if params[:quote_id]
      @quote = Quote.find_by_number(params[:quote_id])
      @quote_title_page = QuoteTitlePage.new(quote: @quote)

      add_crumb @quote.number, quote_path(@quote)
    else
      @quote_title_page = QuoteTitlePage.new
    end

    add_crumb 'Add Title Page'
  end

  def create
    @quote_title_page = QuoteTitlePage.new(quote_title_page_params)
    if @quote_title_page.save
      flash[:success] = "Quote title page created."
      redirect_to(:controller => 'quotes', :action => 'edit', :id => @quote_title_page.quote.number.parameterize)
    else
      render 'new'
    end
  end

  def edit
    if params[:quote_id]
      add_crumb @quote.number, quote_path(@quote)
    end

    add_crumb 'Edit Title Page'
  end

  def update
    if @quote_title_page.update(quote_title_page_params)
      flash[:success] = "Quote title page updated."
      redirect_to(:controller => 'quotes', :action => 'edit', :id => @quote_title_page.quote.number.parameterize)
    else
      render('edit')
    end
  end

  def destroy
    @quote_title_page.destroy
    flash[:success] = "Quote title page deleted."
    redirect_to edit_quote_path(@quote_title_page.quote)
  end

  private
    def set_quote_title_page
      @quote_title_page = QuoteTitlePage.find(params[:id])
      @quote = Quote.find_by_number!(params[:quote_id]) if params[:quote_id]
    end

    def quote_title_page_params
      params.require(:quote_title_page).permit(
        :quote_id,
        :title,
        :image_1,
        :image_2
      )
    end
end
