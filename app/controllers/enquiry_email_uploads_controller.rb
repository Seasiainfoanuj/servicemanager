class EnquiryEmailUploadsController < ApplicationController
 
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_enquiry_email_upload, only: [:show, :edit, :update, :destroy]

  def index
    @enquiry_email_upload = EnquiryEmailUpload.all
  end

  def show
  end

  def new
    if params[:enquiry_id]
      @enquiry = Enquiry.find_by_number!(params[:enquiry_id])
      @enquiry_email_upload = EnquiryEmailUpload.new(:enquiry_id => @enquiry.id)
    else
      @enquiry_email_upload = EnquiryEmailUpload.new
    end
  end

  def edit
  end

  def create
    @enquiry_email_upload = EnquiryEmailUpload.new(enquiry_email_upload_params)
    respond_to do |format|
      if @enquiry_email_upload.save
        format.html {
          render :json => [@enquiry_email_upload.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: {files: [@enquiry_email_upload.to_jq_upload]}, status: :created, location: @enquiry_email_upload }
      else
        format.html { render action: "new" }
        format.json { render json: @enquiry_email_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @enquiry_email_upload.update_attributes(enquiry_email_upload_params)
        format.html { redirect_to @enquiry_email_upload, notice: 'email attachment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @enquiry_email_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @enquiry_email_upload.destroy
    redirect_to(:action => 'index')
  end

  private

    def set_enquiry_email_upload
      if params[:enquiry_id]
        @enquiry_id = params[:enquiry_id]
      end
      @enquiry_email_upload = EnquiryEmailUpload.find(params[:id])
    end

    def enquiry_email_upload_params
      params.require(:enquiry_email_upload).permit(
        :enquiry_id,
        :upload
      )
    end
end

