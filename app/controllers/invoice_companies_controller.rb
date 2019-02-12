class InvoiceCompaniesController < ApplicationController

  before_action :authenticate_user!
  authorize_resource

  before_action :set_company, only: [:show, :edit, :update, :destroy]

  add_crumb("Internal Companies") { |instance| instance.send :invoice_companies_path }

  def index
    session['last_request'] = '/invoice_companies'
    @company = InvoiceCompany.all
  end

  def show
    add_crumb @company.name, @companies
  end

  def new
    @company = InvoiceCompany.new
    add_crumb "New"
  end

  def create
    @company = InvoiceCompany.new(company_params)
    if @company.save
      flash[:success] = "Company added."
      redirect_to(:action => 'index')
    else
      render 'new'
    end
  end

  def edit
    add_crumb @company.name, @invoice_company
    add_crumb 'Edit'
  end

  def update
    if @company.update(company_params)
      flash[:success] = "Company updated."
      redirect_to(:action => 'index')
    else
      render('edit')
    end
  end

  def destroy
    if @company.destroy
      flash[:success] = "#{@company.name} deleted."
      redirect_to(:action => 'index')
    else
      error_msg = ""
      @company.errors.full_messages.each { |e| error_msg << "#{e}. " }
      error_msg = error_msg.humanize.gsub! "record", @company.name
      flash[:error] = "#{error_msg}"
      redirect_to(:action => 'index')
    end
  end

private

  def set_company
    @company = InvoiceCompany.find(params[:id])
  end

  def company_params
    params.require(:invoice_company).permit(
      :accounts_admin_id,
      :name,
      :slug,
      :phone,
      :fax,
      :address_line_1,
      :address_line_2,
      :suburb,
      :state,
      :postcode,
      :country,
      :logo,
      :abn,
      :acn,
      :website
    )
  end
end
