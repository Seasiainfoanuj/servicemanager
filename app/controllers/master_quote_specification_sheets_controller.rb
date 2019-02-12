class MasterQuoteSpecificationSheetsController < ApplicationController

  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_master_quote
  before_action  only: [:show, :edit, :update, :destroy]

  def index
    # We need an array for jQuery plugin compatibility, but we have a has_one relation
    @master_quote_specification_sheets = [@master_quote.specification_sheet].compact
  end

  def show
   
  end

  def new
    if @master_quote
      @master_quote_specification_sheet = MasterQuoteSpecificationSheet.build_specification_sheet
    else
      @master_quote_specification_sheet = MasterQuoteSpecificationSheet.new
    end
  end

  def edit
   
  end

  def create
    @master_quote_specification_sheet =
      @master_quote.build_specification_sheet(master_quote_specification_sheet_params)
    respond_to do |format|
      if @master_quote_specification_sheet.save
        format.html {
          render :json => [@master_quote_specification_sheet.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: {files: [@master_quote_specification_sheet.to_jq_upload]}, status: :created, location: master_quote_specification_sheet_path(@master_quote, @master_quote_specification_sheet) }
      else
        format.html { render action: "new" }
        format.json { render json: @master_quote_specification_sheet.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @master_quote_specification_sheet.update_attributes(master_quote_specification_sheet_params)
        format.html { redirect_to @master_quote_specification_sheet, notice: 'master quote specification sheet was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @master_quote_specification_sheet.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @master_quote_specification_sheet.destroy
    redirect_to action: :index, status: 303
  end

  private

  def set_master_quote
    @master_quote = MasterQuote.find(params[:master_quote_id]) if params[:master_quote_id]
  end

  def set_master_quote_specification_sheet
    @master_quote_specification_sheet = MasterQuoteSpecificationSheet.find(params[:id])
  end

  def master_quote_specification_sheet_params
    params.require(:master_quote_specification_sheet).permit(:upload)
  end
end
