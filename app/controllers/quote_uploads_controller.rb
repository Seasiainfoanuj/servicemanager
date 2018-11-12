class QuoteUploadsController < ApplicationController

  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_quote_upload, only: [:show, :edit, :update, :destroy]

  def index
    @quote_uploads = QuoteUpload.all
  end

  def show
  end

  def new
    if params[:quote_id]
      @quote = Quote.find_by_number!(params[:quote_id])
      @quote_upload = QuoteUpload.new(:quote_id => @quote.id)
    else
      @quote_upload = QuoteUpload.new
    end
  end

  def edit
  end

  def create
    @quote_upload = QuoteUpload.new(quote_upload_params)
    p quote_upload_params
    p "___________________________________"
    respond_to do |format|
      if @quote_upload.save
        format.html {
          render :json => [@quote_upload.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: {files: [@quote_upload.to_jq_upload]}, status: :created, location: @quote_upload }
      else
        format.html { render action: "new" }
        format.json { render json: @quote_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @quote_upload.update_attributes(quote_upload_params)
        format.html { redirect_to @quote_upload, notice: 'quote_upload was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @quote_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @quote_upload.destroy
    redirect_to(:action => 'index')
  end

  private

    def set_quote_upload
      if params[:quote_id]
        @quote_id = params[:quote_id]
      end
      @quote_upload = QuoteUpload.find(params[:id])
    end

    def quote_upload_params
      params.require(:quote_upload).permit(
        :quote_id,
        :upload
      )
    end
end
