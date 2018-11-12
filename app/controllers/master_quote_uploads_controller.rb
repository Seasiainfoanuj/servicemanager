class MasterQuoteUploadsController < ApplicationController

  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_master_quote_upload, only: [:show, :edit, :update, :destroy]

  def index
    @master_quote_uploads = MasterQuoteUpload.all
  end

  def show
  end

  def new
    if params[:master_quote_id]
      @master_quote = Quote.find_by_number!(params[:master_quote_id])
      @master_quote_upload = MasterQuoteUpload.new(:master_quote_id => @master_quote.id)
    else
      @master_quote_upload = MasterQuoteUpload.new
    end
  end

  def edit
  end

  def create
    @master_quote_upload = MasterQuoteUpload.new(master_quote_upload_params)
    respond_to do |format|
      if @master_quote_upload.save
        format.html {
          render :json => [@master_quote_upload.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: {files: [@master_quote_upload.to_jq_upload]}, status: :created, location: @master_quote_upload }
      else
        format.html { render action: "new" }
        format.json { render json: @master_quote_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @master_quote_upload.update_attributes(master_quote_upload_params)
        format.html { redirect_to @master_quote_upload, notice: 'master_quote_upload was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @master_quote_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @master_quote_upload.destroy
    redirect_to(:action => 'index')
  end

  private

    def set_master_quote_upload
      if params[:master_quote_id]
        @master_quote_id = params[:master_quote_id]
      end
      @master_quote_upload = MasterQuoteUpload.find(params[:id])
    end

    def master_quote_upload_params
      params.require(:master_quote_upload).permit(
        :master_quote_id,
        :upload
      )
    end
end
