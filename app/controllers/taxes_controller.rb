class TaxesController < ApplicationController

  before_action :authenticate_user!
  authorize_resource

  before_action :set_tax, only: [:edit, :update, :destroy]

  add_crumb("Taxes") { |instance| instance.send :taxes_path }

  def index
    @taxes = Tax.all
  end

  def new
    @tax = Tax.new
    add_crumb "New"
  end

  def create
    @tax = Tax.new(tax_params)
    if @tax.save
      flash[:success] = "Tax added."
      redirect_to(:action => 'index')
    else
      render 'new'
    end
  end

  def edit
    add_crumb @tax.name, @taxes
    add_crumb 'Edit'
  end

  def update
    if @tax.update(tax_params)
      flash[:success] = "Tax updated."
      redirect_to(:action => 'index')
    else
      render('edit')
    end
  end

  def destroy
    if @tax.quote_items.any?
      flash[:error] = "Tax can't be deleted because it is associated with a quote item."
    elsif @tax.saved_quote_items.any?
      flash[:error] = "Tax can't be deleted because it is associated with a saved quote item."
    else
      @tax.destroy
      flash[:success] = "Tax deleted."
    end

    redirect_to(:action => 'index')
  end

private

  def set_tax
    @tax = Tax.find(params[:id])
  end

  def tax_params
    params.require(:tax).permit(
      :name,
      :rate,
      :rate_percent,
      :number,
      :position
    )
  end

end
