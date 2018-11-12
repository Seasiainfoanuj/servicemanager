class LogUploadsController < ApplicationController

  before_action :authenticate_user!
  authorize_resource
  
  before_action :set_log_upload, only: [:show, :edit, :update, :destroy]

  add_crumb("Log Uploads") { |instance| instance.send :log_uploads_path }

  def index
    if params[:vehicle_log_id]
      @log = VehicleLog.find(params[:vehicle_log_id])
      #@log_uploads = LogUpload.joins(:log_uploads).where('vehicle_log_id = ' + @vehicle_log_id.to_s)
      @log_uploads = VehicleLog.find(params[:vehicle_log_id]).log_uploads
      #@log_uploads = LogUpload.all
    else
      @log_uploads = LogUpload.all
    end
  end

  def show
  end

  def new
    if params[:vehicle_log_id]
      @log = VehicleLog.find(params[:vehicle_log_id])
      @log_upload = LogUpload.new(:vehicle_log_id => @log.id)
    else
      @log_upload = LogUpload.new
    end
  end

  def edit
  end

  def create
    @log_upload = LogUpload.new(log_upload_params)
    respond_to do |format|
      if @log_upload.save
        format.html {
          render :json => [@log_upload.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: {files: [@log_upload.to_jq_upload]}, status: :created, location: @log_upload }
      else
        format.html { render action: "new" }
        format.json { render json: @log_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @log_upload.update_attributes(log_upload_params)
        format.html { redirect_to @log_upload, notice: 'log_upload was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @log_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @log_upload.destroy
  end

private

  def set_log_upload
    if params[:vehicle_log_id]
      @vehicle_log_id = params[:vehicle_log_id]
    end
    @log_upload = LogUpload.find(params[:id])
  end

  def log_upload_params
    params.require(:log_upload).permit(
      :vehicle_log_id,
      :upload
    )
  end

end
