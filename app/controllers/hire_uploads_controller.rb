class HireUploadsController < ApplicationController

  before_action :authenticate_user!
  authorize_resource

  before_action :set_hire_upload, only: [:show, :edit, :update, :destroy]

  add_crumb("Hire Uploads") { |instance| instance.send :hire_uploads_path }

  def index
    if params[:hire_agreement_id]
      @hire = HireAgreement.find(params[:hire_agreement_id])
      #@hire_uploads = HireUpload.joins(:hire_uploads).where('hire_agreement_id = ' + @hire_agreement_id.to_s)
      @hire_uploads = HireAgreement.find(params[:hire_agreement_id]).hire_uploads
      #@hire_uploads = HireUpload.all
    else
      @hire_uploads = HireUpload.all
    end
  end

  def show
  end

  def new
    if params[:hire_agreement_id]
      @hire_agreement = HireAgreement.find(params[:hire_agreement_id])
      @hire_upload = HireUpload.new(:hire_agreement_id => @hire.id)
    else
      @hire_upload = HireUpload.new
    end
  end

  def edit
  end

  def create
    @hire_upload = HireUpload.new(hire_upload_params)
    respond_to do |format|
      if @hire_upload.save
        format.html {
          render :json => [@hire_upload.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: {files: [@hire_upload.to_jq_upload]}, status: :created, location: @hire_upload }
      else
        format.html { render action: "new" }
        format.json { render json: @hire_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @hire_upload.update_attributes(hire_upload_params)
        format.html { redirect_to @hire_upload, notice: 'hire_upload was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @hire_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @hire_upload.destroy
  end

private

  def set_hire_upload
    if params[:hire_agreement_id]
      @hire_agreement_id = params[:hire_agreement_id]
    end
    @hire_upload = HireUpload.find(params[:id])
  end

  def hire_upload_params
    params.require(:hire_upload).permit(
      :hire_agreement_id,
      :upload
    )
  end
end
