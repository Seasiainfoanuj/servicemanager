class SearchTagsController < ApplicationController

  before_action :authenticate_user!
  authorize_resource
  
  before_action :set_search_tag, only: [:edit, :update, :destroy]

  add_crumb("Search Tags") { |instance| instance.send :search_tags_path }

  def index
    @search_tags = SearchTag.all
  end

  def new
    @search_tag = SearchTag.new
    add_crumb 'New'
  end

  def create
    @search_tag = SearchTag.new(search_tag_params)
    if @search_tag.save
      flash[:success] = "Search Tag created."
      redirect_to(action: 'index')
    else
      flash[:error] = "Search Tag could not be created."
      render 'new'
    end  
  end

  def edit
    add_crumb "#{@search_tag.tag_type.to_s.humanize.titleize} - #{@search_tag.name}", @search_tags
    add_crumb 'Edit'
  end

  def update
    if @search_tag.update(search_tag_params)
      flash[:success] = "Search Tag updated."
      redirect_to(action: 'index')
    else
      flash[:error] = "Search Tag could not be updated."
      render 'edit'
    end
  end

  def destroy
    @search_tag.destroy
    flash[:success] = "Search Tag deleted."
    redirect_to(action: 'index')
  end

  private

    def set_search_tag
      @search_tag = SearchTag.find(params[:id])
    end

    def search_tag_params
      params.require(:search_tag).permit(:tag_type, :name)
    end

end