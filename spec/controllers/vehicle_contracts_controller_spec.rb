require "spec_helper"
require "rack/test"

describe VehicleContractsController, type: :controller do
  let(:admin) { FactoryGirl.create(:user, :admin) }
  let(:customer) { FactoryGirl.create(:user, :customer) }
  let(:invoice_company) { FactoryGirl.create(:invoice_company) }
  let(:quote) { FactoryGirl.create(:quote, :accepted, 
                            manager: admin, 
                            invoice_company: invoice_company,
                            customer: customer, 
                            items: [FactoryGirl.build(:quote_item)]) }
  let(:vehicle) { FactoryGirl.create(:vehicle) }

  context "Visiting the show page of a Vehicle Contract" do
    let(:vehicle_contract) { FactoryGirl.create(:vehicle_contract, 
                              quote: quote, 
                              manager: admin,
                              invoice_company: invoice_company,
                              customer: customer,
                              vehicle: vehicle,
                              current_status: 'presented_to_customer') }

    describe "The manager sees the contract details" do
      before do
        signin(admin)
        get :show, id: vehicle_contract.uid
      end

      it { should respond_with 200 }

      it "displays the vehicle contract show template" do
        expect(response).to render_template :show
      end
    end

    describe "The customer attempts to visit the show page" do
      before do
        signin(customer)
        get :show, id: vehicle_contract.uid
      end

      it { should respond_with 302 }

      it "redirects the customer to the view_customer_contract" do
        expect(response).to redirect_to("/vehicle_contracts")
      end
    end
  end


  context "Administrator creates Vehicle Contract" do

    describe "Administrator cannot access the new contract page for a quote that is not accepted" do
      let(:quote) { FactoryGirl.create(:quote,
            invoice_company: invoice_company,
            customer: customer, 
            manager: admin, 
            items: [FactoryGirl.build(:quote_item)]) }
  
      before do
        vehicle_contract_params = {
          quote_id: quote.id, 
          vehicle_id: vehicle.id,
          manager_id: admin.id,
          customer_id: customer.id,
          invoice_company_id: invoice_company.id
        }
        signin(admin)
        request.env["HTTP_REFERER"] = "/quotes/#{quote.number}"
        get :new, vehicle_contract: vehicle_contract_params
      end

      it "creates a vehicle contract" do
        expect(flash[:error]).to eq('Quote cannot not used to create Vehicle Contract.')
        expect(response).to redirect_to("/quotes/#{quote.number}")
      end
    end

    describe "Valid create parameters produce success message" do
      let(:quote) { FactoryGirl.create(:quote, :accepted, 
            invoice_company: invoice_company,
            customer: customer, 
            manager: admin, 
            items: [FactoryGirl.build(:quote_item)]) }
  
      before do
        vehicle_contract_params = {
          quote_id: quote.id, 
          vehicle_id: vehicle.id,
          manager_id: admin.id,
          customer_id: customer.id,
          invoice_company_id: invoice_company.id,
          special_conditions: 'Special conditions for customers'
        }
        signin(admin)
        put :create, vehicle_contract: vehicle_contract_params
      end

      it "creates a vehicle contract" do
        expect(flash[:success]).to eq('Vehicle Contract created.')
        vehicle_contract = VehicleContract.find_by(quote: quote, vehicle: vehicle)
        expect(response).to redirect_to("/vehicle_contracts/#{vehicle_contract.uid.downcase}?referrer=created")
        expect(vehicle_contract.special_conditions).to eq('Special conditions for customers')
      end
    end

    describe "Invalid create parameters produce error message" do
      before do
        vehicle_contract_params = {
          quote_id: quote.id, 
          manager_id: admin.id,
          customer_id: customer.id,
          invoice_company_id: invoice_company.id,
          deposit_received: 11900.00
        }
        signin(admin)
        allow_any_instance_of(VehicleContract).to receive(:valid?).and_return(false)
        put :create, vehicle_contract: vehicle_contract_params
      end

      it "fails to create a vehicle contract" do
        expect(flash[:error]).to eq('Vehicle Contract could not be created.')
      end
    end

    describe "Administrator selects both vehicle and allocated stock" do
      let(:allocated_stock) { FactoryGirl.create(:stock) }

      before do
        vehicle_contract_params = {
          quote_id: quote.id, 
          manager_id: admin.id,
          customer_id: customer.id,
          invoice_company_id: invoice_company.id,
          vehicle_id: vehicle.id,
          allocated_stock_id: allocated_stock.id
        }
        signin(admin)
        put :create, vehicle_contract: vehicle_contract_params
      end

      it "rejects the transaction, complaining about both vehicle and stock being selected" do
        expect(flash[:error]).to eq('Choose either the Allocated Stock or Vehicle, but not both.')
      end
    end

    describe "Administrator select stock with same VIN number as existing vehicle" do
      let(:allocated_stock) { FactoryGirl.create(:stock, vin_number: vehicle.vin_number) }

      before do
        vehicle_contract_params = {
          quote_id: quote.id, 
          manager_id: admin.id,
          customer_id: customer.id,
          invoice_company_id: invoice_company.id,
          allocated_stock_id: allocated_stock.id
        }
        signin(admin)
        put :create, vehicle_contract: vehicle_contract_params
      end

      it "rejects the transaction, complaining about the pre-existing vin number" do
        expect(flash[:error]).to eq('A vehicle with this VIN number already exists in the database. Selected allocated stock might be invalid.')
      end
    end
  end

  context "Administrator updates Vehicle Contract" do
    let(:vehicle_contract) { FactoryGirl.create(:vehicle_contract, 
                              quote: quote, 
                              manager: admin,
                              invoice_company: invoice_company,
                              customer: customer,
                              vehicle: vehicle,
                              special_conditions: 'Special conditions for customers') }

    describe "Administrator is allowed to edit a draft contract" do
      before do
        signin(admin)
        get :edit, id: vehicle_contract.uid
      end

      it { should respond_with 200 }

      it "displays the vehicle contract edit template" do
        expect(response).to render_template :edit
      end
    end

    describe "Administrator attempts to edit a signed contract" do
      before do
        vehicle_contract.current_status = "signed"
        vehicle_contract.save
        signin(admin)
        request.env["HTTP_REFERER"] = "/vehicle_contracts"
        get :edit, id: vehicle_contract.uid
      end

      it { should respond_with 302 }

      it "rejects the edit, complaining about the current contract status" do
        expect(flash[:error]).to eq('A vehicle contract with status of Signed may not be updated.')
      end
    end

    describe "Valid update parameters produce success message" do
      before do
        vehicle_contract_params = {
          quote_id: quote.id, 
          vehicle_id: vehicle.id,
          special_conditions: 'No special conditions'
        }
        signin(admin)
        put :update, id: vehicle_contract.uid, vehicle_contract: vehicle_contract_params
      end

      it "updates a vehicle contract" do
        expect(flash[:success]).to eq('Vehicle Contract updated.')
        vehicle_contract.reload
        expect(response).to redirect_to("/vehicle_contracts/#{vehicle_contract.uid}?referrer=updated")
        expect(vehicle_contract.special_conditions).to eq('No special conditions')
      end
    end

    describe "Invalid update parameters produce error message" do
      before do
        vehicle_contract_params = {
          quote_id: quote.id, 
          vehicle_id: nil,
          manager_id: nil,
          invoice_company_id: quote.invoice_company.id,
          special_conditions: 'No special conditions'
        }
        signin(admin)
        put :update, id: vehicle_contract.uid, vehicle_contract: vehicle_contract_params
      end
      it "fails to update a vehicle contract" do
        expect(flash[:error]).to eq('Vehicle Contract could not be updated.')
        vehicle_contract.reload
        expect(vehicle_contract.special_conditions).to eq('Special conditions for customers')
      end
    end

    describe "The administrator updates a vehicle contract that was already presented to the customer" do
      before do
        vehicle_contract_params = {
          quote_id: quote.id, 
          vehicle_id: vehicle.id,
          special_conditions: 'No special conditions'
        }
        vehicle_contract.current_status = 'presented_to_customer'
        vehicle_contract.save
        signin(admin)
        put :update, id: vehicle_contract.uid, vehicle_contract: vehicle_contract_params
      end

      it "redirects the administrator to the show page" do
        expect(flash[:error]).to eq('A vehicle contract with status of Presented To Customer may not be updated.')
        expect(response).to redirect_to("/vehicle_contracts/#{vehicle_contract.uid}")
      end
    end
  end

  context "Administrator views Vehicle Contracts" do
    let(:quote1) { FactoryGirl.create(:quote, :accepted, manager: admin, customer: customer, items: [FactoryGirl.build(:quote_item)]) }
    let(:quote2) { FactoryGirl.create(:quote, :accepted, manager: admin, customer: customer, items: [FactoryGirl.build(:quote_item)]) }
    let(:vehicle1) { FactoryGirl.create(:vehicle) }
    let(:vehicle2) { FactoryGirl.create(:vehicle) }

    describe "Can access vehicle contracts index page when there are no contracts" do
      before do
        signin(admin)
        get :index
      end

      it { should respond_with 200 }

      it "displays an empty list" do
        expect(response).to render_template :index
      end
    end  

    describe "Can access available vehicle contracts on the index page", :js => true do
      before do
        @vehicle_contract1 = FactoryGirl.create(:vehicle_contract, 
                                customer: customer, 
                                manager: admin,
                                invoice_company: invoice_company,
                                quote: quote1, 
                                vehicle: vehicle1,
                                special_conditions: 'Special conditions for customers 1')
        @vehicle_contract2 = FactoryGirl.create(:vehicle_contract, 
                                customer: customer, 
                                manager: admin,
                                invoice_company: invoice_company,
                                quote: quote2, 
                                vehicle: vehicle2,
                                special_conditions: 'Special conditions for customers 2')
        signin(admin)
        get :index
      end

      it { should respond_with 200 }

      it "renders the index page successfully" do
        expect(response).to render_template :index
      end
    end  
  end  

  context "Administrator verifies Vehicle Contract" do
    let(:vehicle_contract) { FactoryGirl.create(:vehicle_contract, 
                              quote: quote, 
                              manager: admin,
                              invoice_company: invoice_company,
                              customer: customer,
                              vehicle: vehicle,
                              special_conditions: 'Special conditions for customers') }

    describe "Valid verify parameters produce success message" do
      before do
        signin(admin)
        put :verify_customer_info, id: vehicle_contract.uid
      end

      it "verifies a vehicle contract" do
        expect(flash[:success]).to eq('The customer details for this contract have been verified.')
        vehicle_contract.reload
        expect(response).to redirect_to("/vehicle_contracts/#{vehicle_contract.uid}?referrer=verify_customer_info")
      end
    end
  end

  context "Administrator sends Vehicle Contract to customer" do
    let(:customer) { FactoryGirl.create(:user, :customer, email: 'royknox@example.com') }
    let(:vehicle_contract) { FactoryGirl.create(:vehicle_contract, 
                              quote: quote, 
                              manager: admin,
                              invoice_company: invoice_company,
                              customer: customer,
                              vehicle: vehicle,
                              current_status: 'verified') }

    describe "Valid 'send_contract' parameters produce success message" do
      before do
        signin(admin)
        put :send_contract, vehicle_contract_id: vehicle_contract.uid
      end

      it "sends the vehicle contract to the customer" do
        allow(VehicleContractMailer).to receive(:vehicle_contract_email).and_return(nil)
        expect(flash[:success]).to eq('Vehicle Contract sent to royknox@example.com.')
        vehicle_contract.reload
        expect(response).to redirect_to("/vehicle_contracts/#{vehicle_contract.uid}")
      end
    end
  end

  context "Authorised customer views the html version of their own contract" do
    let(:vehicle_contract) { FactoryGirl.create(:vehicle_contract, 
                              quote: quote, 
                              manager: admin,
                              invoice_company: invoice_company,
                              customer: customer,
                              vehicle: vehicle,
                              current_status: 'presented_to_customer') }

    describe "Valid update parameters produce success message" do
      before do
        signin(customer)
        get :view_customer_contract, id: vehicle_contract.uid
      end

      it { should respond_with 200 }

      it "renders the correct template" do
        expect(response).to render_template :view_customer_contract
      end
    end
  end

  context "Authorised customer reviews Vehicle Contract" do
    let(:vehicle_contract) { FactoryGirl.create(:vehicle_contract, 
                              quote: quote, 
                              manager: admin,
                              invoice_company: invoice_company,
                              customer: customer,
                              vehicle: vehicle,
                              current_status: 'presented_to_customer') }

    describe "Valid update parameters produce success message" do
      before do
        signin(customer)
        get :review, id: vehicle_contract.uid
      end

      it { should respond_with 200 }

      it "renders the correct template" do
        expect(response).to render_template :review
      end
    end
  end

  context "Authorised customer accepts their Vehicle Contract" do
    let(:vehicle_contract) { FactoryGirl.create(:vehicle_contract, 
                              quote: quote, 
                              manager: admin,
                              invoice_company: invoice_company,
                              customer: customer,
                              vehicle: vehicle,
                              current_status: 'presented_to_customer') }

    describe "The customer sees a success message after accepting the contract" do
      before do
        signin(customer)
        put :accept, id: vehicle_contract.uid
      end

      it "gives a confirmation message to the customer" do
        allow(VehicleContractMailer).to receive(:vehicle_contract_email).and_return(nil)
        expect(flash[:success]).to eq('Vehicle Contract accepted.')
        expect(response).to redirect_to("/vehicle_contracts/#{vehicle_contract.uid}/view_customer_contract")
      end
    end
  end

  context "Customer uploads their Vehicle Contract" do
    let(:vehicle_contract) { FactoryGirl.create(:vehicle_contract, 
                              quote: quote, 
                              manager: admin,
                              invoice_company: invoice_company,
                              customer: customer,
                              vehicle: vehicle,
                              current_status: 'presented_to_customer') }

    describe "The customer sees a success message after uploading their contract" do
      before do
        signin(customer)
        file = fixture_file_upload('images/delivery_sheet.pdf', 'application/pdf')
        vehicle_contract_params = { signed_contract_attributes: { upload: file } }
        request.env["HTTP_REFERER"] = "/vehicle_contracts/#{vehicle_contract.uid}/view_customer_contract"
        put :upload_contract, id: vehicle_contract.uid, vehicle_contract: vehicle_contract_params
      end

      it "renders the correct template" do
        expect(vehicle_contract.signed_contract.upload_file_name).to eq('delivery_sheet.pdf')
      end
    end

    describe "The customer attempts an upload without selecting a file" do
      before do
        signin(customer)
        request.env["HTTP_REFERER"] = "/vehicle_contracts/#{vehicle_contract.uid}/view_customer_contract"
        put :upload_contract, id: vehicle_contract.uid
      end

      it "reports that no file was selecting" do
        expect(flash[:error]).to eq('A file has not yet been selected.')
      end
    end

    describe "The customer attempts an upload while contract has a verified status" do
      before do
        vehicle_contract.current_status = "verified"
        vehicle_contract.save
        signin(customer)
        file = fixture_file_upload('images/delivery_sheet.pdf', 'application/pdf')
        vehicle_contract_params = { signed_contract_attributes: { upload: file } }
        request.env["HTTP_REFERER"] = "/vehicle_contracts/#{vehicle_contract.uid}/view_customer_contract"
        put :upload_contract, id: vehicle_contract.uid, vehicle_contract: vehicle_contract_params
      end

      it "reports that the current status does not allow the upload" do
        expect(flash[:error]).to eq('This action is currently not permitted.')
      end
    end

  end

  context "Customer attempts unauthorised access" do
    let(:vehicle_contract) { FactoryGirl.create(:vehicle_contract, 
                              quote: quote, 
                              manager: admin,
                              invoice_company: invoice_company,
                              customer: customer,
                              vehicle: vehicle,
                              current_status: 'verified') }
    describe "The customer visits the 'customer contract' page of a verified contract" do
      before do
        signin(customer)
        get :view_customer_contract, id: vehicle_contract.uid
      end

      it { should respond_with 302 }
    end 
  end

end

