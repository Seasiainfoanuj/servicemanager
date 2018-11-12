class PoRequestUploadsController < ApplicationController

  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_po_request_upload, only: [:show, :edit, :update, :destroy]

  def index
    @po_request_uploads = PoRequestUpload.all
  end

  def show
  end

  def new
    if params[:po_request_id]
      @po_request = PoRequest.find_by_number!(params[:po_request_id])
      @po_request_upload = PoRequestUpload.new(:po_request_id => @po_request.id)
    else
      @po_request_upload = PoRequestUpload.new
    end
  end

  def edit
  end

  def create
    @po_request_upload = PoRequestUpload.new(po_request_upload_params)
    respond_to do |format|
      if @po_request_upload.save
        format.html {
          render :json => [@po_request_upload.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: {files: [@po_request_upload.to_jq_upload]}, status: :created, location: @po_request_upload }
      else
        format.html { render action: "new" }
        format.json { render json: @po_request_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @po_request_upload.update_attributes(po_request_upload_params)
        format.html { redirect_to @po_request_upload, notice: 'po_request_upload was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @po_request_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @po_request_upload.destroy
  end

  private

    def set_po_request_upload
      if params[:po_request_id]
        @po_request_id = params[:po_request_id]
      end
      @po_request_upload = PoRequestUpload.find(params[:id])
    end

    def po_request_upload_params
      params.require(:po_request_upload).permit(
        :po_request_id,
        :upload
      )
    end
end
