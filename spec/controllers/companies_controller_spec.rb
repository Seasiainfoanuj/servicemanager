require "spec_helper"
require "rack/test"

describe CompaniesController, type: :controller do
  let(:admin) { create(:user, :admin) }

  context "Administrator views Companies" do
    let(:company) { create(:company, name: 'Tomlinson & Sons', abn: '21600023916', 
                            client_attributes: { client_type: 'company' }) }

    describe "Visit Companies Index page" do
      render_views

      before do
        signin(admin)
        get :index
      end

      it { should respond_with 200 }

      it "displays the companies template" do
        expect(response).to render_template :index
        expect(response.body).to match /Companies/
      end
    end

    describe "Visit Company Show page" do
      render_views

      before do
        create_company_addresses
        create_company_contacts
        signin(admin)
        get :show, id: company.id
      end

      it { should respond_with 200 }

      it "displays the company addresses" do
        expect(response).to render_template :show
        expect(response.body).to match /Tomlinson &amp; Sons/
        expect(response.body).to match(company.abn)
        expect(response.body).to match /200 Tourist Drive, Thornley, QLD, 4690/
        expect(response.body).to match /bill.gates@example.com/
      end
    end
  end

  context "Administrator creates a Company" do
    describe "Visit New Company page" do
      before do
        signin(admin)
        get :new
      end

      it { should respond_with 200 }

      it "displays the new template" do
        expect(response).to render_template :new
      end
    end

    describe "Create new company" do
      before do
        signin(admin)
        put :create, company: { name: "Harvey Norman" }
      end

      it "creates a new company" do
        expect(flash[:success]).to eq('Company, Harvey Norman, has been added.')
        expect(Company.find_by(name: 'Harvey Norman').name).to eq('Harvey Norman')
      end
    end

    describe "Creating company with incorrect parameters" do
      before do
        signin(admin)
        put :create, company: { name: "B" }
      end

      it "creates a new company" do
        expect(flash[:error]).to eq('Failed to create company.')
      end
    end
  end

  context "Administrator updates a Company" do
    let(:company) { create(:company, name: 'Tomlinson & Sons', abn: '21600023916', 
                            client_attributes: { client_type: 'company' }) }

    describe "Visit Edit Company page" do
      before do
        signin(admin)
        get :edit, id: company.id
      end

      it { should respond_with 200 }

      it "displays the edit template" do
        expect(response).to render_template :edit
      end
    end

    describe "Update Company" do
      render_views

      before do
        signin(admin)
        put :update, id: company.id, company: { name: 'The Tomlins', trading_name: 'Tomlins Enterprise'}
      end

      it "updates the company" do
        expect(flash[:success]).to eq('Company, The Tomlins, has been updated.')
        expect(company.reload.trading_name).to eq('Tomlins Enterprise')
      end
    end

    describe "Updating Company with incorrect parameters" do
      before do
        signin(admin)
        put :update, id: company.id, company: { name: 'T', trading_name: 'T'}
      end

      it "displays an error message" do
        expect(flash[:error]).to eq('Failed to update company.')
        expect(response).to render_template :edit
      end
    end
  end

  context "Administrator deletes a Company" do
    let(:company) { create(:company, name: 'Tomlinson', 
                            client_attributes: { client_type: 'company' }) }

    describe "Deleting Company" do
      before do
        signin(admin)
        delete :destroy, id: company.id
      end

      it "deletes the company" do
        expect(flash[:success]).to eq('Company deleted.')
        expect(Company.exists?(id: company.id)).to eq(nil)
      end
    end

    describe "Deleting company with contacts" do
      before do
        create_company_contacts
        signin(admin)
        delete :destroy, id: company.id
      end

      it "deletes the company" do
        expect(flash[:error]).to eq("Cannot delete company, #{company.name}. It still has contacts.")
      end
    end
  end

  context "Administrator adds contact to company" do
    let(:company) { create(:company, name: 'Tomlinson', client_attributes: { client_type: 'company' }) }
    let(:contact) { create(:user, :contact, email: 'susan@me.com', client_attributes: { client_type: 'person'}) }

    describe "Adding contact to company" do
      before do
        signin(admin)
        put :add_contact, id: company.id, user_id: contact.id
      end

      it "adds the contact to the company" do
        expect(flash[:success]).to eq("#{contact.first_name} #{contact.last_name} has been added to #{company.name}")
        expect(contact.reload.representing_company_id).to eq(company.id)
      end
    end

  end

  private

    def create_company_addresses
      company.addresses.create(address_type: Address::POSTAL, line_1: '200 Tourist Drive', 
        suburb: 'Thornley', state: 'QLD', postcode: '4690')
    end

    def create_company_contacts
      create(:user, :contact, email: 'bill.gates@example.com', 
        representing_company_id: company.id, client_attributes: { client_type: 'person'})
    end
end