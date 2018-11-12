require "spec_helper"
require "rack/test"

describe HireProductTypesController, type: :controller do

  context "Administrator creates Hire Product Type" do
    let(:admin) { FactoryGirl.create(:user, :admin) }

    describe "Valid create parameters produce success message" do
      before do
        signin(admin)
        put :create, hire_product_type: { name: 'Motorhome' }
      end

      it "should create a new Hire Product type" do
        expect(flash[:success]).to eq('Hire Product Type created.')
        expect(HireProductType.exists?(name: 'Motorhome')).to eq(1)
      end
    end

    describe "Invalid create parameters produce error message" do
      before do
        signin(admin)
        put :create, hire_product_type: { name: '' }
      end

      it "should not create a new Hire Product type" do
        expect(flash[:error]).to eq('Hire Product Type could not be created.')
      end
    end
  end

  context "Administrator updates Hire Product Type" do
    let(:admin) { FactoryGirl.create(:user, :admin) }
    let(:hire_product_type) { HireProductType.create(name: 'Mine Spec') }

    describe "Valid update parameters produce success message" do
      before do
        signin(admin)
        put :update, id: hire_product_type.id, hire_product_type: { name: 'Mine Spec2' }
      end

      it "should update the Hire Product type" do
        expect(flash[:success]).to eq('Hire Product Type updated.')
        expect(hire_product_type.reload.name).to eq('Mine Spec2')
      end
    end

    describe "Invalid update parameters produce error message" do
      before do
        signin(admin)
        put :update, id: hire_product_type.id, hire_product_type: { name: '' }
      end

      it "should not update the Hire Product type" do
        expect(flash[:error]).to eq('Hire Product Type could not be updated.')
      end
    end
  end

  context "Administrator views list of Hire Product Types" do
    render_views
    
    let(:admin) { FactoryGirl.create(:user, :admin) }
    let(:hire_product_type) { HireProductType.create(name: 'Motorhome') }

    describe "Access the index page" do
      before do
        signin(admin)
        get :index
      end
    
      it { should respond_with 200 }

      it "Available HireProductTypes are listed" do
        expect(response).to render_template :index
        expect(response.body).to match /Hire Product Types/im 
        # Cannot test more because of datatables:
        # http://everydayrails.com/2012/04/07/testing-series-rspec-controllers.html
      end
    end
  end  
end