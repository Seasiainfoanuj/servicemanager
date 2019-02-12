class PhotoCategoriesController < ApplicationController

  before_action :authenticate_user!
  authorize_resource
  
  before_action :set_photo_category, only: [:edit, :update, :destroy]

  add_crumb("Photo Category") { |instance| instance.send :photo_categories_path }

  def index
    @photo_categories = PhotoCategory.all
  end

  def new
    @photo_category = PhotoCategory.new
    add_crumb 'New'
  end

  def create
    @photo_category = PhotoCategory.new(photo_category_params)
    if @photo_category.save
      flash[:success] = "Photo category added."
      redirect_to(action: 'index')
    else
      error_msg = ""
      @photo_category.errors.full_messages.each { |e| error_msg << "#{e}. " }
      flash[:error] = "#{error_msg}"
      render 'new'
    end  
  end

  def edit
    add_crumb @photo_category.name, @photo_categories
    add_crumb 'Edit'
  end

  def update
    if @photo_category.update(photo_category_params)
      flash[:success] = "Photo category updated."
      redirect_to(action: 'index')
    else
      error_msg = ""
      @photo_category.errors.full_messages.each { |e| error_msg << "#{e}. " }
      flash[:error] = "#{error_msg}"
      render 'edit'
    end
  end

  def destroy
    @photo_category.destroy
    flash[:success] = "Photo category deleted."
    redirect_to(action: 'index')
  end

  private

    def set_photo_category
      @photo_category = PhotoCategory.find(params[:id])
    end

    def photo_category_params
      params.require(:photo_category).permit(
        :name
      )
    end

end  