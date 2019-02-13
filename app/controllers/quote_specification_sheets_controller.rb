class QuoteSpecificationSheetsController < ApplicationController

  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_quote
  before_action :set_quote_specification_sheet, only: [:show, :edit, :update, :destroy]

  def index
    # We need an array for jQuery plugin compatibility, but we have a has_one relation
    @quote_specification_sheet = [@quote.specification_sheet].compact
  end
  

  def show
  end

  def new
    if @quote
      @quote_specification_sheet = @quote.build_specification_sheet
    else
      @quote_specification_sheet = QuoteSpecificationSheet.new
    end
  end

  def edit
  end

  def create
    @quote_specification_sheet =
      @quote.build_specification_sheet(quote_specification_sheet_params)
    respond_to do |format|
      if @quote_specification_sheet.save
        format.html {
          render :json => [@quote_specification_sheet.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: {files: [@quote_specification_sheet.to_jq_upload]}, status: :created, location: quote_specification_sheet_path(@quote, @quote_specification_sheet) }
      else
        format.html { render action: "new" }
        format.json { render json: @quote_specification_sheet.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @quote_specification_sheet.update_attributes(quote_specification_sheet_params)
        format.html { redirect_to @quote_specification_sheet, notice: 'quote specification sheet was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @quote_specification_sheet.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @quote_specification_sheet.destroy
    redirect_to action: :index, status: 303
  end

  private

  def set_quote
    @quote = Quote.find_by(number: params[:quote_id]) if params[:quote_id]
  end

  def set_quote_specification_sheet
    @quote_specification_sheet = QuoteSpecificationSheet.find(params[:id])
  end

  def quote_specification_sheet_params
    params.require(:quote_specification_sheet).permit(:upload)
  end
end
