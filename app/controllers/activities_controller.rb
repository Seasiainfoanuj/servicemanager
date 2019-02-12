class ActivitiesController < ApplicationController
  before_filter :authenticate_user!

  def index
    respond_to do |format|
      format.html
      format.json { render json: ActivitiesDatatable.new(view_context, current_user) }
    end
  end
end
