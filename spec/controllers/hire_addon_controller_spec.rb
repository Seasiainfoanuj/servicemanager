require "spec_helper"
require "rack/test"

describe HireAddonsController, type: :controller do
  let(:admin) { FactoryGirl.create(:user, :admin, email: 'sam@me.com') }

  context "Visiting the show page of a Hire Addon" do
    let!(:hire_addon) { HireAddon.create(
        addon_type: 'GPS',
        model_name: 'Delux24',
        hire_price_cents: 50000,
        billing_frequency: 'daily'
      )}

    describe "Admin user visits Hire Addon Show page" do
      before do
        signin(admin)
        get :show, id: hire_addon.id
      end
      
      it { should respond_with 200 }  

      it "renders the correct page" do
        expect(response).to render_template :show
      end
    end

    describe "Non-logged-in user visits Hire Add-on Show page" do
      before do
        get :show, id: hire_addon.id
      end
      
      it { should respond_with 302 }  
    end
  end

  context "Administrator views list of Hire Addons" do
    render_views

    let!(:hire_addon) { create(:hire_addon) }

    describe "Access the index page" do
      before do
        signin(admin)
        get :index
      end

      it { should respond_with 200 }

      it "Lists available Hire Add-ons" do
        expect(response).to render_template :index
        expect(response.body).to match /Hire Add-ons/
      end  
    end  
  end
  
  context "Administrator creates Hire Add-on" do
    describe "Administrator visits New Hire Add-on page" do
      before do
        signin(admin)
        get :new
      end
      
      it { should respond_with 200 }

      it "displays the new add-on template" do
        expect(response).to render_template :new
      end
    end

    describe "Valid create parameters produce success message" do
      before do
        hire_addon_params = {
          addon_type: 'Seat Sense', 
          model_name: 'MX730',
          hire_price: '644.50',
          billing_frequency: "weekly"
        }

        signin(admin)
        put :create, hire_addon: hire_addon_params
      end

      it "should create a new Hire Add-on" do
        expect(flash[:success]).to eq('Hire Add-on created.')
        seat_sense = HireAddon.find_by(model_name: 'MX730')
        expect(seat_sense.hire_price_cents).to eq(64450)
        expect(seat_sense.billing_frequency).to eq("weekly")
      end
    end

    describe "Invalid create parameters produce error message" do
      before do
        hire_addon_params = {
          addon_type: 'Seat Sense', 
          model_name: '',
          hire_price: '644.50',
          billing_frequency: "weekly"
        }

        signin(admin)
        put :create, hire_addon: hire_addon_params
      end

      it "should not create a new Hire Add-on" do
        expect(flash[:error]).to eq('Hire Add-on could not be created.')
      end
    end
  end    

  context "Administrator updates Hire Add-on" do
    let!(:hire_addon) { HireAddon.create(
        addon_type: 'GPS',
        model_name: 'Delux24',
        hire_price_cents: 50000,
        billing_frequency: 'daily'
      )}

    describe "Administrator visits Edit Hire Add-on page" do
      before do
        signin(admin)
        get :edit, id: hire_addon.id
      end

      it { should respond_with 200 }

      it "displays the edit add-on template" do
        expect(response).to render_template :edit
      end
    end

    describe "Administrator updates Hire Add-on with valid parameters" do
      before do
        signin(admin)
        addon_params = { addon_type: 'Seat Sense', model_name: 'LongRide 1000', hire_price: '699.50', billing_frequency: 'weekly'}
        put :update, id: hire_addon.id, hire_addon: addon_params
      end

      it "updates the add-on" do
        expect(flash[:success]).to eq("Hire Addon updated.")
        hire_addon.reload
        expect(hire_addon.addon_type).to eq('Seat Sense')
        expect(hire_addon.model_name).to eq('LongRide 1000')
        expect(hire_addon.hire_price_cents).to eq(69950)
        expect(hire_addon.billing_frequency).to eq('weekly')
      end
    end  

    describe "Administrator tries to update Hire Add-on with invalid parameters" do
      before do
        signin(admin)
        addon_params = { addon_type: 'Seat Sense', model_name: 'LongRide 1000', hire_price: '699.50', billing_frequency: 'allways'}
        put :update, id: hire_addon.id, hire_addon: addon_params
      end

      it "updates the add-on" do
        expect(flash[:error]).to eq("Hire Addon could not be updated.")
        hire_addon.reload
        expect(hire_addon.addon_type).to eq('GPS')
      end
    end  
  end
end
