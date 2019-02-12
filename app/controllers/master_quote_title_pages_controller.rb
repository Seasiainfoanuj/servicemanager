class MasterQuoteTitlePagesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_master_quote_title_page, only: [:edit, :update, :destroy]

#add_crumb("Master Quotes") { |instance| instance.send :master_quotes_path }

  def new
    if params[:master_quote_id]
      @master_quote = MasterQuote.find(params[:master_quote_id])
      @master_quote_title_page = MasterQuoteTitlePage.new(master_quote: @master_quote)

      #add_crumb @master_quote.name, master_quote_path(@master_quote)
    else
      @master_quote_title_page = MasterQuoteTitlePage.new
    end

    add_crumb 'Add Title Page'
  end

  def create
    @master_quote_title_page = MasterQuoteTitlePage.new(master_quote_title_page_params)
    if @master_quote_title_page.save
      flash[:success] = "Master quote title page created."
      @master_quote = @master_quote_title_page.master_quote
      if @master_quote.international
         redirect_to edit_master_quotes_international_path(@master_quote_title_page.master_quote)
      else
         redirect_to edit_master_quote_path(@master_quote_title_page.master_quote)
      end   
    else
      render 'new'
    end
  end

  def edit
    if params[:master_quote_id]
      add_crumb @master_quote.name, master_quote_path(@master_quote)
    end

    add_crumb 'Edit Title Page'
  end

  def update
    if @master_quote_title_page.update(master_quote_title_page_params)
      flash[:success] = "Master quote title page updated."
      @master_quote = @master_quote_title_page.master_quote
      if @master_quote.international
         redirect_to edit_master_quotes_international_path(@master_quote_title_page.master_quote)
      else
         redirect_to edit_master_quote_path(@master_quote_title_page.master_quote)
      end 
    else
      render('edit')
    end
  end

  def destroy
    @master_quote_title_page.destroy
    flash[:success] = "Master quote title page deleted."
    @master_quote = @master_quote_title_page.master_quote
    if @master_quote.international
        redirect_to edit_master_quotes_international_path(@master_quote_title_page.master_quote)
    else
        redirect_to edit_master_quote_path(@master_quote_title_page.master_quote)
    end   
  end

  private
    def set_master_quote_title_page
      @master_quote_title_page = MasterQuoteTitlePage.find(params[:id])
      @master_quote = MasterQuote.find(params[:master_quote_id]) if params[:master_quote_id]
    end

    def master_quote_title_page_params
      params.require(:master_quote_title_page).permit(
        :master_quote_id,
        :title,
        :image_1,
        :image_2
      )
    end
end
