class OnHireReportUploadsController < ApplicationController

  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_on_hire_report_upload, only: [:show, :edit, :update, :destroy]

  def index
    if params[:on_hire_report_id]
      @on_hire_report = OnHireReport.find(params[:on_hire_report_id])
      #@on_hire_report_uploads = OnHireReportUpload.joins(:on_hire_report_uploads).where('on_hire_report_id = ' + @on_hire_report_id.to_s)
      @on_hire_report_uploads = OnHireReport.find(params[:on_hire_report_id]).on_hire_report_uploads
      #@on_hire_report_uploads = OnHireReportUpload.all
    else
      @on_hire_report_uploads = OnHireReportUpload.all
    end
  end

  def show
  end

  def new
    if params[:on_hire_report_id]
      @on_hire_report = OnHireReport.find(params[:on_hire_report_id])
      @on_hire_report_upload = OnHireReportUpload.new(:on_hire_report_id => @hire.id)
    else
      @on_hire_report_upload = OnHireReportUpload.new
    end
  end

  def edit
  end

  def create
    @on_hire_report_upload = OnHireReportUpload.new(on_hire_report_upload_params)
    respond_to do |format|
      if @on_hire_report_upload.save
        format.html {
          render :json => [@on_hire_report_upload.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: {files: [@on_hire_report_upload.to_jq_upload]}, status: :created, location: @on_hire_report_upload }
      else
        format.html { render action: "new" }
        format.json { render json: @on_hire_report_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @on_hire_report_upload.update_attributes(on_hire_report_upload_params)
        format.html { redirect_to @on_hire_report_upload, notice: 'on_hire_report_upload was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @on_hire_report_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @on_hire_report_upload.destroy
  end

private

  def set_on_hire_report_upload
    if params[:on_hire_report_id]
      @on_hire_report_id = params[:on_hire_report_id]
    end
    @on_hire_report_upload = OnHireReportUpload.find(params[:id])
  end

  def on_hire_report_upload_params
    params.require(:on_hire_report_upload).permit(
      :on_hire_report_id,
      :upload
    )
  end
end
