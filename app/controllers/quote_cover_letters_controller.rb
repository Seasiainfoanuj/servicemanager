class QuoteCoverLettersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_quote_cover_letter, only: [:edit, :update, :destroy]

  add_crumb("Quotes") { |instance| instance.send :quotes_path }

  def new
    if params[:quote_id]
      @quote = Quote.find_by_number(params[:quote_id])
      @quote_cover_letter = QuoteCoverLetter.new(quote: @quote)

      add_crumb @quote.number, quote_path(@quote)
    else
      @quote_cover_letter = QuoteCoverLetter.new
    end

    add_crumb 'Add Cover Letter'
  end

  def create
    @quote_cover_letter = QuoteCoverLetter.new(quote_cover_letter_params)
    if @quote_cover_letter.save
      flash[:success] = "Quote cover letter created."
      redirect_to(:controller => 'quotes', :action => 'edit', :id => @quote_cover_letter.quote.number.parameterize)
    else
      render 'new'
    end
  end

  def edit
    if params[:quote_id]
      add_crumb @quote.number, quote_path(@quote)
    end

    add_crumb 'Edit Cover Letter'
  end

  def update
    if @quote_cover_letter.update(quote_cover_letter_params)
      flash[:success] = "Quote cover letter updated."
      redirect_to(:controller => 'quotes', :action => 'edit', :id => @quote_cover_letter.quote.number.parameterize)
    else
      render('edit')
    end
  end

  def destroy
    @quote_cover_letter.destroy
    flash[:success] = "Quote cover letter deleted."
    redirect_to edit_quote_path(@quote_cover_letter.quote)
  end

  private
    def set_quote_cover_letter
      @quote_cover_letter = QuoteCoverLetter.find(params[:id])
      @quote = Quote.find_by_number!(params[:quote_id]) if params[:quote_id]
    end

    def quote_cover_letter_params
      params.require(:quote_cover_letter).permit(
        :quote_id,
        :title,
        :text
      )
    end
end
