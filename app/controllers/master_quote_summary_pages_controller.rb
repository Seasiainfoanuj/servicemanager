class MasterQuoteSummaryPagesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_master_quote_summary_page, only: [:edit, :update, :destroy]

  #add_crumb("Master Quotes") { |instance| instance.send :master_quotes_path }

  def new
    if params[:master_quote_id]
      @master_quote = MasterQuote.find(params[:master_quote_id])
      @master_quote_summary_page = MasterQuoteSummaryPage.new(master_quote: @master_quote)

      #add_crumb @master_quote.name, master_quote_path(@master_quote)
    else
      @master_quote_summary_page = MasterQuoteSummaryPage.new
    end

    add_crumb 'Add Summary Page'
  end

  def create
    @master_quote_summary_page = MasterQuoteSummaryPage.new(master_quote_summary_page_params)
    if @master_quote_summary_page.save
      flash[:success] = "Master quote summary page created."
      @master_quote = @master_quote_summary_page.master_quote
      if @master_quote.international
         redirect_to edit_master_quotes_international_path(@master_quote_summary_page.master_quote)
      else
         redirect_to edit_master_quote_path(@master_quote_summary_page.master_quote)
      end 
    else
      render 'new'
    end
  end

  def edit
    if params[:master_quote_id]
      #add_crumb @master_quote.name, master_quote_path(@master_quote)
    end

    add_crumb 'Edit Summary Page'
  end

  def update
    if @master_quote_summary_page.update(master_quote_summary_page_params)
      flash[:success] = "Master quote summary page updated."
      @master_quote = @master_quote_summary_page.master_quote
      if @master_quote.international
         redirect_to edit_master_quotes_international_path(@master_quote_summary_page.master_quote)
      else
         redirect_to edit_master_quote_path(@master_quote_summary_page.master_quote)
      end 
    else
      render('edit')
    end
  end

  def destroy
    @master_quote_summary_page.destroy
    flash[:success] = "Master quote summary page deleted."
    @master_quote = @master_quote_summary_page.master_quote
      if @master_quote.international
         redirect_to edit_master_quotes_international_path(@master_quote_summary_page.master_quote)
      else
         redirect_to edit_master_quote_path(@master_quote_summary_page.master_quote)
      end 
    
  end

  private
    def set_master_quote_summary_page
      @master_quote_summary_page = MasterQuoteSummaryPage.find(params[:id])
      @master_quote = MasterQuote.find(params[:master_quote_id]) if params[:master_quote_id]
    end

    def master_quote_summary_page_params
      params.require(:master_quote_summary_page).permit(
        :master_quote_id,
        :text
      )
    end
end
