class FileUploadsController < ApplicationController

  before_action :authenticate_user!
  authorize_resource

  before_action :set_file_upload, only: [:show, :edit, :update, :destroy]

  add_crumb("File Uploads") { |instance| instance.send :file_uploads_path }

  def index
    if params[:workorder_id]
      @workorder = Workorder.find(params[:workorder_id])
      #@file_uploads = FileUpload.joins(:workorder_uploads).where('workorder_id = ' + @workorder_id.to_s)
      #@file_uploads = Workorder.find(params[:workorder_id]).file_uploads
      @file_uploads = @workorder.file_uploads
    end
  end

  def show
  end

  def new
    @file_upload = FileUpload.new
  end

  def edit
  end

  def create
    @file_upload = FileUpload.new(file_upload_params)

    respond_to do |format|
      if @file_upload.save
        format.html {
          render :json => [@file_upload.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: {files: [@file_upload.to_jq_upload]}, status: :created, location: @file_upload }
      else
        format.html { render action: "new" }
        format.json { render json: @file_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @file_upload.update_attributes(file_upload_params)
        format.html { redirect_to @file_upload, notice: 'file_upload was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @file_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @file_upload.destroy
  end

private

  def set_file_upload
    if params[:workorder_id]
      @workorder_id = params[:workorder_id]
    end
    @file_upload = FileUpload.find(params[:id])
  end

  def file_upload_params
    params.require(:file_upload).permit(
      :name,
      :upload
    )
  end
end
