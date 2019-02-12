class BuildUploadsController < ApplicationController

  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_build_upload, only: [:show, :edit, :update, :destroy]

  def index
    if params[:build_id]
      @build = Build.find(params[:build_id])
      #@build_uploads = BuildUpload.joins(:build_uploads).where('build_id = ' + @build_id.to_s)
      @build_uploads = Build.find(params[:build_id]).build_uploads
      #@build_uploads = BuildUpload.all
    else
      @build_uploads = BuildUpload.all
    end
  end

  def show
  end

  def new
    if params[:build_id]
      @build = Build.find(params[:build_id])
      @build_upload = BuildUpload.new(:build_id => @build.id)
    else
      @build_upload = BuildUpload.new
    end
  end

  def edit
  end

  def create
    @build_upload = BuildUpload.new(build_upload_params)
    respond_to do |format|
      if @build_upload.save
        format.html {
          render :json => [@build_upload.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: {files: [@build_upload.to_jq_upload]}, status: :created, location: @build_upload }
      else
        format.html { render action: "new" }
        format.json { render json: @build_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @build_upload.update_attributes(build_upload_params)
        format.html { redirect_to @build_upload, notice: 'build_upload was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @build_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @build_upload.destroy
  end

private

  def set_build_upload
    if params[:build_id]
      @build_id = params[:build_id]
    end
    @build_upload = BuildUpload.find(params[:id])
  end

  def build_upload_params
    params.require(:build_upload).permit(
      :build_id,
      :upload
    )
  end
end
