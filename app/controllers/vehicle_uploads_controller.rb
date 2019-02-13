class VehicleUploadsController < ApplicationController

  before_action :authenticate_user!
  authorize_resource

  before_action :set_vehicle_upload, only: [:show, :edit, :update, :destroy]

  add_crumb("Vehicle Uploads") { |instance| instance.send :vehicle_uploads_path }

  def index
    if params[:vehicle_id]
      @vehicle = Vehicle.find(params[:vehicle_id])
      @vehicle_uploads = Vehicle.find(params[:vehicle_id]).vehicle_uploads
    else
      @vehicle_uploads = VehicleUpload.all
    end
  end

  def show
  end

  def new
    if params[:vehicle_id]
      @vehicle = Vehicle.find(params[:vehicle_id])
      @vehicle_upload = VehicleUpload.new(:vehicle_id => @vehicle.id)
    else
      @vehicle_upload = VehicleUpload.new
    end
  end

  def edit
  end

  def create
    @vehicle_upload = VehicleUpload.new(vehicle_upload_params)
    respond_to do |format|
      if @vehicle_upload.save
        format.html {
          render :json => [@vehicle_upload.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: {files: [@vehicle_upload.to_jq_upload]}, status: :created, location: @vehicle_upload }
      else
        format.html { render action: "new" }
        format.json { render json: @vehicle_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @vehicle_upload.update_attributes(vehicle_upload_params)
        format.html { redirect_to @vehicle_upload, notice: 'vehicle_upload was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @vehicle_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @vehicle_upload.destroy
  end

private

  def set_vehicle_upload
    if params[:vehicle_id]
      @vehicle_id = params[:vehicle_id]
    end
    @vehicle_upload = VehicleUpload.find(params[:id])
  end

  def vehicle_upload_params
    params.require(:vehicle_upload).permit(
      :vehicle_id,
      :upload
    )
  end
end
