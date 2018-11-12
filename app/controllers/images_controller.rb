class ImagesController < ApplicationController
  before_action :authenticate_user!
  authorize_resource
  before_action :set_image, only: [:show, :edit, :update, :destroy]

  def index
    @documents = image_subject.images.documents
    @photos = image_subject.images.photos
    if image_subject.class.name == 'Vehicle'
      add_crumb "Vehicles", vehicles_path
      add_crumb @subject.name, vehicle_path(@subject)
      add_crumb "Images"
    end
  end

  def new_document
    @image = image_subject.images.new
    @image_type = Image::DOCUMENT
    add_crumb "Vehicles", vehicles_path
    add_crumb @subject.name, vehicle_path(@subject)
    add_crumb "Documents", vehicle_images_path(@subject)
    render :new
  end

  def new_photo
    @image = image_subject.images.new
    @image_type = Image::PHOTO
    add_crumb "Vehicles", vehicles_path
    add_crumb @subject.name, vehicle_path(@subject)
    add_crumb "Photos", vehicle_images_path(@subject)
    render :new
  end

  def create
    @image = image_subject.images.new(image_params)
    if image_params['image'].present? && image_params['name'].blank?
      @image.name = get_photo_or_document_type
    end
    respond_to do |format|
      if @image.save
        format.html { 
          flash[:success] = "A #{@image.image_type_name} has been created."
          redirect_to vehicle_images_path(image_subject)
        }
        format.json { render action: 'show', status: :created, location: [image_subject, @image]}
      else
        @image_type = @image.image_type
        errors = ""
        @image.errors.full_messages.each { |msg| errors += "- #{msg}<br>" }
        msg = "The following errors prevented #{@image.image_type_name} from being created: <br>#{errors.to_s}".html_safe
        format.html { 
          flash[:error] = msg
          render :new
        }
        format.json { render json: msg, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @subject = image_subject
    @image_type = @image.image_type
    add_crumb "Vehicles", vehicles_path
    add_crumb @subject.name, vehicle_path(@subject)
    add_crumb "Images", vehicle_images_path(@subject)
    add_crumb @image.name
  end

  def update
    respond_to do |format|
      if @image.update_attributes(image_params)
        format.html { 
          flash[:success] = "The #{@image.image_type_name} has been updated."
          redirect_to vehicle_images_path(image_subject)
        }
        format.json { head :no_content }
      else
        errors = ""
        @image.errors.full_messages.each { |msg| errors += "- #{msg}<br>" }
        msg = "The following errors prevented #{@image.image_type_name} from being updated: <br>#{errors.to_s}".html_safe
        format.html { 
          flash[:error] = msg
          render :edit
        }
        format.json { render json: msg, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @image.delete
    flash[:success] = "The image #{@image.image_type_name} has been deleted." 
    redirect_to vehicle_images_path(image_subject)
  end

  private
    def image_params
      params.require(:image).permit(
        :image_type,
        :document_type_id,
        :photo_category_id,
        :image,
        :name,
        :description
      )
    end

    def get_photo_or_document_type
      if image_params['document_type_id'].present?
        @image.document_type.name
      else
        @image.photo_category.name
      end
    end

    def image_subject
      if params['vehicle_id'].present?
        @subject = Vehicle.where(id: params['vehicle_id']).first
        @vehicle = @subject
      end
    end

    def set_image
      if params[:id].present?
        @image = Image.find(params[:id])
      end
    rescue
      @image = nil    
    end
end
