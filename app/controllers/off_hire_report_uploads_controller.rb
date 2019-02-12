class OffHireReportUploadsController < ApplicationController

  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_off_hire_report_upload, only: [:show, :edit, :update, :destroy]

  def index
    if params[:off_hire_report_id]
      @hire = OffHireReport.find(params[:off_hire_report_id])
      #@off_hire_report_uploads = OffHireReportUpload.joins(:off_hire_report_uploads).where('off_hire_report_id = ' + @off_hire_report_id.to_s)
      @off_hire_report_uploads = OffHireReport.find(params[:off_hire_report_id]).off_hire_report_uploads
      #@off_hire_report_uploads = OffHireReportUpload.all
    else
      @off_hire_report_uploads = OffHireReportUpload.all
    end
  end

  def show
  end

  def new
    if params[:off_hire_report_id]
      @hire_agreement = OffHireReport.find(params[:off_hire_report_id])
      @off_hire_report_upload = OffHireReportUpload.new(:off_hire_report_id => @hire.id)
    else
      @off_hire_report_upload = OffHireReportUpload.new
    end
  end

  def edit
  end

  def create
    @off_hire_report_upload = OffHireReportUpload.new(off_hire_report_upload_params)
    respond_to do |format|
      if @off_hire_report_upload.save
        format.html {
          render :json => [@off_hire_report_upload.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: {files: [@off_hire_report_upload.to_jq_upload]}, status: :created, location: @off_hire_report_upload }
      else
        format.html { render action: "new" }
        format.json { render json: @off_hire_report_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @off_hire_report_upload.update_attributes(off_hire_report_upload_params)
        format.html { redirect_to @off_hire_report_upload, notice: 'off_hire_report_upload was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @off_hire_report_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @off_hire_report_upload.destroy
  end

private

  def set_off_hire_report_upload
    if params[:off_hire_report_id]
      @off_hire_report_id = params[:off_hire_report_id]
    end
    @off_hire_report_upload = OffHireReportUpload.find(params[:id])
  end

  def off_hire_report_upload_params
    params.require(:off_hire_report_upload).permit(
      :off_hire_report_id,
      :upload
    )
  end
end
