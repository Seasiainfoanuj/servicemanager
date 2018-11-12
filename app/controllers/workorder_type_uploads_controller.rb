class WorkorderTypeUploadsController < ApplicationController

  before_action :authenticate_user!
  authorize_resource

  before_action :set_workorder_type_upload, only: [:show, :edit, :update, :destroy]

  def index
    if params[:workorder_type_id]
      @workorder_type = WorkorderType.find(params[:workorder_type_id])
      @workorder_type_uploads = WorkorderType.find(params[:workorder_type_id]).workorder_type_uploads
    else
      @workorder_type_uploads = WorkorderTypeUpload.all
    end
  end

  def show
  end

  def new
    if params[:workorder_type_id]
      @workorder_type = WorkorderType.find(params[:workorder_type_id])
      @workorder_type_upload = WorkorderTypeUpload.new(:workorder_type_id => @workorder_type.id)
    else
      @workorder_type_upload = WorkorderTypeUpload.new
    end
  end

  def edit
  end

  def create
    @workorder_type_upload = WorkorderTypeUpload.new(workorder_type_upload_params)
    respond_to do |format|
      if @workorder_type_upload.save
        format.html {
          render :json => [@workorder_type_upload.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: {files: [@workorder_type_upload.to_jq_upload]}, status: :created, location: @workorder_type_upload }
      else
        format.html { render action: "new" }
        format.json { render json: @workorder_type_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @workorder_type_upload.update_attributes(workorder_type_upload_params)
        format.html { redirect_to @workorder_type_upload, notice: 'workorder_type_upload was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @workorder_type_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @workorder_type_upload.destroy
  end

private

  def set_workorder_type_upload
    if params[:workorder_type_id]
      @workorder_type_id = params[:workorder_type_id]
    end
    @workorder_type_upload = WorkorderTypeUpload.find(params[:id])
  end

  def workorder_type_upload_params
    params.require(:workorder_type_upload).permit(
      :workorder_type_id,
      :upload
    )
  end

end
