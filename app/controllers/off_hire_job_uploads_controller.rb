class OffHireJobUploadsController < ApplicationController

  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_off_hire_job_upload, only: [:show, :edit, :update, :destroy]

  def index
    if params[:off_hire_job_id]
      @off_hire_job = OffHireJob.find(params[:off_hire_job_id])
      #@off_hire_job_uploads = OffHireJobUpload.joins(:off_hire_job_uploads).where('off_hire_job_id = ' + @off_hire_job_id.to_s)
      @off_hire_job_uploads = OffHireJob.find(params[:off_hire_job_id]).off_hire_job_uploads
      #@off_hire_job_uploads = OffHireJobUpload.all
    else
      @off_hire_job_uploads = OffHireJobUpload.all
    end
  end

  def show
  end

  def new
    if params[:off_hire_job_id]
      @off_hire_job = OffHireJob.find(params[:off_hire_job_id])
      @off_hire_job_upload = OffHireJobUpload.new(:off_hire_job_id => @off_hire_job.id)
    else
      @off_hire_job_upload = OffHireJobUpload.new
    end
  end

  def edit
  end

  def create
    @off_hire_job_upload = OffHireJobUpload.new(off_hire_job_upload_params)
    respond_to do |format|
      if @off_hire_job_upload.save
        format.html {
          render :json => [@off_hire_job_upload.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: {files: [@off_hire_job_upload.to_jq_upload]}, status: :created, location: @off_hire_job_upload }
      else
        format.html { render action: "new" }
        format.json { render json: @off_hire_job_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @off_hire_job_upload.update_attributes(off_hire_job_upload_params)
        format.html { redirect_to @off_hire_job_upload, notice: 'off_hire_job_upload was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @off_hire_job_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @off_hire_job_upload.destroy
  end

private

  def set_off_hire_job_upload
    if params[:off_hire_job_id]
      @off_hire_job_id = params[:off_hire_job_id]
    end
    @off_hire_job_upload = OffHireJobUpload.find(params[:id])
  end

  def off_hire_job_upload_params
    params.require(:off_hire_job_upload).permit(
      :off_hire_job_id,
      :upload
    )
  end
end
