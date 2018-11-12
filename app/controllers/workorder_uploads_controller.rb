class WorkorderUploadsController < ApplicationController

  before_action :authenticate_user!
  authorize_resource

  before_action :set_workorder_upload, only: [:show, :edit, :update, :destroy]

  add_crumb("Workorder Uploads") { |instance| instance.send :workorder_uploads_path }

  def index
    if params[:workorder_id]
      @workorder = Workorder.find(params[:workorder_id])
      #@workorder_uploads = workorderUpload.joins(:workorder_uploads).where('workorder_id = ' + @workorder_id.to_s)
      @workorder_uploads = Workorder.find(params[:workorder_id]).workorder_uploads
      #@workorder_uploads = WorkorderUpload.all
    else
      @workorder_uploads = WorkorderUpload.all
    end
  end

  def show
  end

  def new
    if params[:workorder_id]
      @workorder = Workorder.find(params[:workorder_id])
      #@workorder_uploads = workorderUpload.joins(:workorder_uploads).where('workorder_id = ' + @workorder_id.to_s)
      #@workorder_uploads = Workorder.find(params[:workorder_id]).workorder_uploads
      @workorder_upload = WorkorderUpload.new(:workorder_id => @workorder.id)
    else
      @workorder_upload = WorkorderUpload.new
    end
  end

  def edit
  end

  def create
    @workorder_upload = WorkorderUpload.new(workorder_upload_params)
    respond_to do |format|
      if @workorder_upload.save
        format.html {
          render :json => [@workorder_upload.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: {files: [@workorder_upload.to_jq_upload]}, status: :created, location: @workorder_upload }
      else
        format.html { render action: "new" }
        format.json { render json: @workorder_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @workorder_upload.update_attributes(workorder_upload_params)
        format.html { redirect_to @workorder_upload, notice: 'workorder_upload was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @workorder_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @workorder_upload.destroy
  end

private

  def set_workorder_upload
    if params[:workorder_id]
      @workorder_id = params[:workorder_id]
    end
    @workorder_upload = WorkorderUpload.find(params[:id])
  end

  def workorder_upload_params
    params.require(:workorder_upload).permit(
      :workorder_id,
      :upload
    )
  end
end
