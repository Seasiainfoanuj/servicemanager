require "spec_helper"
require "rack/test"

describe HireQuotesController, type: :controller do
  let!(:customer) { create(:user, :customer, email: 'yvonne@me.com', client_attributes: { client_type: 'person'}) }
  let!(:manager)  { create(:user, :admin, email: 'eugene@me.com', client_attributes: { client_type: 'person'}) }

  context "Visiting the show page of a Hire Quote" do
    let!(:hire_quote) { create(:hire_quote, customer: customer.client, manager: manager.client, status: 'sent') }

    describe "Manager views Hire Quote Show page" do
      before do
        signin(manager)
        get :show, id: hire_quote.reference
      end

      it { should respond_with 200 }

      it "displays the hire quote template" do
        expect(response).to render_template :show
      end
    end

    describe "Customer views the show page of their own quote" do
      before do
        signin(customer)
        get :show, id: hire_quote.reference
      end

      it { should respond_with 302 }

      it "redirects the customer to the 'view customer quote' page" do
        expect(response).to redirect_to("/hire_quotes/#{hire_quote.reference.upcase}/view_customer_quote")
      end
    end

    describe "Wrong customer views the show page of a hire quote" do
      let!(:wrong_customer) { create(:user, :customer, email: 'brian@me.com', client_attributes: { client_type: 'person'}) }

      before do
        signin(wrong_customer)
        get :show, id: hire_quote.reference
      end

      it { should respond_with 302 }

      it "redirects the customer to the home page" do
        expect(response).to redirect_to(root_url)
      end
    end
  end

  context "Visiting the 'view customer quote' page of a Hire Quote" do
    let!(:hire_quote) { create(:hire_quote, customer: customer.client, manager: manager.client, status: 'sent') }
    let!(:invoice_company) {create(:invoice_company_2, slug: 'bus_hire', accounts_admin: manager)}
    render_views

    describe "Customer visits 'view customer quote' page of their own quote" do
      before do
        create(:tax, name: "GST", rate: 0.1)
        create_hire_quote_details
        signin(customer)
        get :view_customer_quote, id: hire_quote.reference
      end

      it { should respond_with 200 }

      it "displays the view customer quote template" do
        expect(response).to render_template :view_customer_quote
      end
    end
  end

  context "Visiting the index page of Hire Quotes" do
    let!(:hire_quote) { HireQuote.create(customer: customer.client, manager: manager.client, tags: 'Motorhome') }

    describe "Manager visits Hire Quotes index page" do
      render_views
      before do
        signin(manager)
        get :index
      end

      it { should respond_with 200 }

      it "displays the hire quotes index template" do
        expect(response).to render_template :index
        expect(response.body).to match /Motorhome/
      end
    end
  end

  context "Creating a new Hire Quote" do
    describe "Manager visits New Hire Quote page" do
      before do
        signin(manager)
        get :new
      end

      it { should respond_with 200 }

      it "displays a new hire quote template" do
        expect(response).to render_template :new
      end
    end

    describe "Manager creates new Hire Quote" do
      before do
        hire_quote_params = {
          customer_id: customer.client.id,
          manager_id: manager.client.id,
          tags: 'Popular'
        }
        signin(manager)
        put :create, hire_quote: hire_quote_params
      end

      it "should create a new hire quote" do
        quote = HireQuote.last
        expect(flash[:success]).to eq("Hire Quote #{quote.reference} created.")
        expect(quote.tags).to eq('Popular')
      end
    end

    describe "Manager cannot create Hire Quote with incorrect tags" do
      before do
        hire_quote_params = {
          customer_id: customer.client.id,
          manager_id: manager.client.id,
          tags: "Abc"
        }
        signin(manager)
        put :create, hire_quote: hire_quote_params
      end

      it "should display an error message" do
        expect(flash[:error]).to eq("Incorrect tags provided. All tags must be 4 characters or longer.")
      end
    end

    describe "Manager cannot create Hire Quote with incorrect parameters" do
      before do
        hire_quote_params = {
          customer_id: customer.client.id,
          manager_id: nil
        }
        signin(manager)
        put :create, hire_quote: hire_quote_params
      end

      it "should display an error message" do
        expect(flash[:error]).to eq("Hire Quote could not be created.")
      end
    end
  end

  context "Updating a Hire Quote" do
    let!(:hire_quote) { HireQuote.create(manager: manager.client, customer: customer.client) }

    describe "Manager visits the Edit Hire Quote page" do
      before do
        signin(manager)
        get :edit, id: hire_quote.reference
      end

      it { should respond_with 200 }

      it "displays a edit hire quote template" do
        expect(response).to render_template :edit
      end
    end

    describe "Manager updates Hire Quote" do
      before do
        hire_quote_params = {
          customer_id: customer.client.id,
          manager_id: manager.client.id,
          tags: "Special"
        }
        signin(manager)
        put :update, id: hire_quote.reference, hire_quote: hire_quote_params
      end

      it "should update the hire quote" do
        expect(flash[:success]).to eq("Hire Quote #{hire_quote.reference} updated.")
        expect(hire_quote.reload.tags).to eq("Special")
        expect(SearchTag.find_by(name: "Special")).not_to eq(nil)
      end
    end

    describe "Manager cannot update Hire Quote with invalid tag" do
      before do
        hire_quote_params = {
          customer_id: customer.client.id,
          manager_id: manager.client.id,
          tags: "Abc"
        }
        signin(manager)
        put :update, id: hire_quote.reference, hire_quote: hire_quote_params
      end

      it "should display an error message" do
        expect(response).to render_template :edit
        expect(flash[:error]).to eq("Incorrect tags provided. All tags must be 4 characters or longer.")
      end
    end

    describe "Manager cannot update Hire Quote with invalid parameters" do
      before do
        hire_quote_params = {
          customer_id: nil,
          manager_id: manager.client.id,
          tags: "Low Range"
        }
        signin(manager)
        put :update, id: hire_quote.reference, hire_quote: hire_quote_params
      end

      it "should display an error message" do
        expect(response).to render_template :edit
        expect(flash[:error]).to eq("Hire Quote could not be updated.")
      end
    end
  end

  context "Administrator sends Hire Quote to customer" do
    let!(:hire_quote) { HireQuote.create(manager: manager.client, customer: customer.client) }

    describe "Display an appropriate message" do
      before do
        signin(manager)
        allow(HireQuoteMailer).to receive(:quote_email).and_return(nil)
        allow_any_instance_of(HireQuote).to receive(:admin_may_perform_action?).and_return(true)
        put :send_quote, id: hire_quote.reference
      end

      it "successfully sends the hire quote to the customer" do
        expect(flash[:success]).to eq("Quote sent to #{customer.email}")
        expect(response).to redirect_to("/hire_quotes/#{hire_quote.reference}")
      end

      it "encounters an error when updating the hire quote" do
      end
    end
  end

  context "Customer accepts their own Hire Quote" do
    let!(:hire_quote) { HireQuote.create(manager: manager.client, customer: customer.client, status: 'sent') }
    let!(:invoice_company) {create(:invoice_company, slug: 'bus_hire', accounts_admin: manager)}

    describe "Processes action and display confirmation message" do
      before do
        signin(customer)
        allow(HireQuoteMailer).to receive(:accept_notification_email).and_return(nil)
        allow_any_instance_of(HireQuote).to receive(:customer_may_perform_action?).and_return(true)
        put :accept, id: hire_quote.reference
      end

      it "successfully accepts the hire quote" do
        expect(flash[:success]).to eq("Quote accepted. The Hire Manager has been informed.")
        expect(response).to redirect_to("/hire_quotes/#{hire_quote.reference.upcase}/view_customer_quote?referrer=accepted")
      end
    end
  end

  context "Customer requests changes to their Hire Quote" do
    let!(:hire_quote) { HireQuote.create(manager: manager.client, customer: customer.client, status: 'sent') }
    let!(:invoice_company) {create(:invoice_company, slug: 'bus_hire', accounts_admin: manager)}

    describe "Processes action and display confirmation message" do
      before do
        signin(customer)
        allow(HireQuoteMailer).to receive(:request_changes_email).and_return(nil)
        allow_any_instance_of(HireQuote).to receive(:customer_may_perform_action?).and_return(true)
        put :request_change, id: hire_quote.reference
      end

      it "successfully accepts the hire quote" do
        expect(flash[:success]).to eq("Changes have been requested. We will be in touch with you shortly. Thank you.")
        expect(response).to redirect_to("/hire_quotes/#{hire_quote.reference.upcase}/view_customer_quote?referrer=request_change")
      end
    end
  end

  context "Manager create Hire Quote amendment" do
    let!(:hire_quote) { HireQuote.create(manager: manager.client, customer: customer.client) }
    let!(:invoice_company) {create(:invoice_company, slug: 'bus_hire', accounts_admin: manager)}

    describe "Process amendment and display confirmation message" do
      before do
        hire_quote.update(status: 'sent')
        create_hire_quote_details
        signin(manager)
        post :create_amendment, id: hire_quote.reference
        hire_quote.reload
      end

      it "cancels the current hire quote" do
        expect(hire_quote.status).to eq("cancelled")
        hire_quote2 = HireQuote.find_latest_quote_by_uid(hire_quote.uid)
        expect(hire_quote2.status).to eq('draft')
      end
    end
  end

  private

    def create_hire_quote_details
      fee_type_1 = create(:fee_type, name: 'Cleaning Fee')
      fee1 = create(:hire_fee, fee_type: fee_type_1, chargeable: fee_type_1)
      fee_type_2 = create(:fee_type, name: 'Flag Replacement')
      fee2 = create(:hire_fee, fee_type: fee_type_2, chargeable: fee_type_2)
      vehicle_make = create(:vehicle_make, name: 'Isuzu')
      vehicle_model = create(:vehicle_model, make: vehicle_make, name: 'LX400', daily_rate_cents: 55000)
      hire_quote_vehicle = create(:hire_quote_vehicle, hire_quote: hire_quote, vehicle_model: vehicle_model, start_date: Date.new(2016,12,1), end_date: Date.new(2017,12,1))
      hire_quote_vehicle.update(fees_attributes: { 
      "0" => {fee_type_id: fee_type_1.id, fee_cents: 14955, chargeable_type: 'HireQuoteVehicle', 
              chargeable_id: hire_quote_vehicle.id}, 
      "1" => {fee_type_id: fee_type_2.id, fee_cents: 11955, chargeable_type: 'HireQuoteVehicle', 
              chargeable_id: hire_quote_vehicle.id}})
    end

end
