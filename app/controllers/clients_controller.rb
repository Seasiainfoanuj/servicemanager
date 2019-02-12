class ClientsController < ApplicationController

  before_action :authenticate_user!
  load_resource :find_by => :reference_number
  authorize_resource

  before_action :set_client, only: [:show, :edit, :update]

  add_crumb('Clients') { |instance| instance.send :clients_path }

  def index
    session['last_request'] = '/clients'
    @clients = Client.includes(:company, user: :invoice_company)
    add_crumb 'All Clients'
    respond_to  do |format|
      format.html
      format.json do 
        render json: ClientsDatatable.new(view_context, current_user, @clients)
      end  
      format.csv do
        @clients = []
        Client.includes(:company, user: :representing_company).map do |client|
          if client.client_type == "person"
            if client.user.representing_company.present?
              @clients << [client.id, client.reference_number, 'Person', client.user.first_name, client.user.last_name, client.user.email, client.user.phone.to_s, client.user.mobile.to_s, client.user.company, client.user.representing_company.name]
            else
              @clients << [client.id, client.reference_number, 'Person', client.user.first_name, client.user.last_name, client.user.email, client.user.phone.to_s, client.user.mobile.to_s, client.user.company, '---']
            end
          else
            @clients << [client.id, client.reference_number, 'Company', '---', '---', '---', '---', '---', '---', client.company.name]
          end
        end  
        render csv: @clients
      end  
    end
  end

  def show
    redirect_to :back if @client.nil? 
    add_crumb @client.name, @clients
  end

  def edit
    add_crumb @client.name, client_path(@client.reference_number)
    add_crumb 'Edit'
  end

  def update
    if @client.update(client_params)
      flash[:success] = "Client updated."
      redirect_to(:action => 'index')
    else
      render('edit')
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find_by(reference_number: params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def client_params
      params.require(:client).permit(
        :roles_mask,
        roles: [:employee, :supplier, :service_provider, :customer, :quote_customer, :contact])
    end

end
