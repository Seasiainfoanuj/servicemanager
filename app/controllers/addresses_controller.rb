class AddressesController < ApplicationController

  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_address, only: [:edit, :update, :destroy]

  def index
    @addresses = Address.all
  end

  def edit
  end

  def update
    if @address.update_attributes(address_params)
      flash[:success] = "Address has been updated."
      redirect_to(:action => 'edit')
    else
      flash["error"] = "Failed to update address"
      render('edit')
    end
  end

  def destroy
    @address.destroy 
    flash[:success] = "Address deleted."
    redirect_to(:action => 'index')
  end

  private

    def set_address
      @address = Address.find(params[:id])
    end

    def address_params
      params.require(:address).permit(
        :address_type, :line_1, :line_2, :suburb, :state, :postcode, :country
        )
    end
 
end

