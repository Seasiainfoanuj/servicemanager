class HireAgreementTypeUploadsController < ApplicationController

  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_hire_agreement_type_upload, only: [:show, :edit, :update, :destroy]

  add_crumb("Hire Agreement Type Uploads") { |instance| instance.send :hire_agreement_type_uploads_path }

  def index
    if params[:hire_agreement_type_id]
      @hire = HireAgreementType.find(params[:hire_agreement_type_id])
      #@hire_agreement_type_uploads = HireAgreementTypeUpload.joins(:hire_agreement_type_uploads).where('hire_agreement_type_id = ' + @hire_agreement_type_id.to_s)
      @hire_agreement_type_uploads = HireAgreementType.find(params[:hire_agreement_type_id]).hire_agreement_type_uploads
      #@hire_agreement_type_uploads = HireAgreementTypeUpload.all
    else
      @hire_agreement_type_uploads = HireAgreementTypeUpload.all
    end
  end

  def show
  end

  def new
    if params[:hire_agreement_type_id]
      @hire_agreement = HireAgreementType.find(params[:hire_agreement_type_id])
      @hire_agreement_type_upload = HireAgreementTypeUpload.new(:hire_agreement_type_id => @hire.id)
    else
      @hire_agreement_type_upload = HireAgreementTypeUpload.new
    end
  end

  def edit
  end

  def create
    @hire_agreement_type_upload = HireAgreementTypeUpload.new(hire_agreement_type_upload_params)
    respond_to do |format|
      if @hire_agreement_type_upload.save
        format.html {
          render :json => [@hire_agreement_type_upload.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: {files: [@hire_agreement_type_upload.to_jq_upload]}, status: :created, location: @hire_agreement_type_upload }
      else
        format.html { render action: "new" }
        format.json { render json: @hire_agreement_type_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @hire_agreement_type_upload.update_attributes(hire_agreement_type_upload_params)
        format.html { redirect_to @hire_agreement_type_upload, notice: 'hire_agreement_type_upload was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @hire_agreement_type_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @hire_agreement_type_upload.destroy
  end

private

  def set_hire_agreement_type_upload
    if params[:hire_agreement_type_id]
      @hire_agreement_type_id = params[:hire_agreement_type_id]
    end
    @hire_agreement_type_upload = HireAgreementTypeUpload.find(params[:id])
  end

  def hire_agreement_type_upload_params
    params.require(:hire_agreement_type_upload).permit(
      :hire_agreement_type_id,
      :upload
    )
  end
end
