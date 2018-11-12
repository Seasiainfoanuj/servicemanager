class BuildOrderUploadsController < ApplicationController

  before_action :authenticate_user!
  authorize_resource

  before_action :set_build_order_upload, only: [:show, :edit, :update, :destroy]

  def index
    if params[:build_order_id]
      @build_order = BuildOrder.find(params[:build_order_id])
      @build_order_uploads = @build_order.build_order_uploads
    else
      @build_order_uploads = BuildOrderUpload.all
    end
  end

  def new
    if params[:build_order_id]
      @build_order = BuildOrder.find(params[:build_order_id])
      @build_order_upload = BuildOrderUpload.new(:build_order_id => @build_order.id)
    else
      @build_order_upload = BuildOrderUpload.new
    end
  end

  def create
    @build_order_upload = BuildOrderUpload.new(build_order_upload_params)
    respond_to do |format|
      if @build_order_upload.save
        format.html {
          render :json => [@build_order_upload.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: {files: [@build_order_upload.to_jq_upload]}, status: :created, location: @build_order_upload }
      else
        format.html { render action: "new" }
        format.json { render json: @build_order_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @build_order_upload.update_attributes(build_order_upload_params)
        format.html { redirect_to @build_order_upload, notice: 'build_order_upload was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @build_order_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @build_order_upload.destroy
  end

private

  def set_build_order_upload
    if params[:build_order_id]
      @build_order_id = params[:build_order_id]
    end
    @build_order_upload = BuildOrderUpload.find(params[:id])
  end

  def build_order_upload_params
    params.require(:build_order_upload).permit(
      :build_order_id,
      :upload
    )
  end

end
