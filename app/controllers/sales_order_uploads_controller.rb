class SalesOrderUploadsController < ApplicationController

  before_action :authenticate_user!
  authorize_resource

  before_action :set_sales_order_upload, only: [:show, :edit, :update, :destroy]

  add_crumb("Sales Order Uploads") { |instance| instance.send :sales_order_uploads_path }

  def index
    if params[:sales_order_id]
      @sales_order = SalesOrder.find(params[:sales_order_id])
      @uploads = SalesOrder.find(params[:sales_order_id]).uploads
    else
      @uploads = SalesOrderUpload.all
    end
  end

  def show
  end

  def new
    if params[:sales_order_id]
      @sales_order = SalesOrder.find(params[:sales_order_id])
      @upload = SalesOrderUpload.new(:sales_order_id => @sales_order.id)
    else
      @upload = SalesOrderUpload.new
    end
  end

  def edit
  end

  def create
    @upload = SalesOrderUpload.new(upload_params)
    respond_to do |format|
      if @upload.save
        format.html {
          render :json => [@upload.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: {files: [@upload.to_jq_upload]}, status: :created, location: @upload }
      else
        format.html { render action: "new" }
        format.json { render json: @upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @upload.update_attributes(upload_params)
        format.html { redirect_to @upload, notice: 'sales_order_upload was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @upload.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @upload.destroy
  end

private

  def set_sales_order_upload
    if params[:sales_order_id]
      @sales_order_id = params[:sales_order_id]
    end
    @upload = SalesOrderUpload.find(params[:id])
  end

  def upload_params
    params.require(:sales_order_upload).permit(
      :sales_order_id,
      :upload
    )
  end
end
