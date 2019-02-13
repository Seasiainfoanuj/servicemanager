require "spec_helper"
require "rack/test"

describe FeeTypesController, type: :controller do
  let(:admin) { FactoryGirl.create(:user, :admin) }

  context "Administrator creates Fee Type" do
    describe "Visit New Fee Type page" do
      before do
        signin(admin)
        get :new
      end

      it { should respond_with 200 }

      it "displays the new fee type template" do
        expect(response).to render_template :new
      end
    end

    describe "Create Fee Type without standard fee" do
      before do
        fee_type_params = {
          category: 'vehicle', 
          charge_unit: 'per_km',
          name: 'Excess charge per km'
        }

        signin(admin)
        put :create, fee_type: fee_type_params
      end

      it "should create a new fee type" do
        expect(flash[:success]).to eq('Fee Type created.')
        fee_type = FeeType.find_by(name: 'Excess charge per km')
        expect(fee_type.charge_unit).to eq('per_km')
        expect(fee_type.standard_fee).to eq(nil)
      end
    end

    describe "Creating Fee Type with errors produces error message" do
      before do
        fee_type_params = {
          category: 'vehicle', 
          charge_unit: 'per_km',
          name: ''
        }

        signin(admin)
        put :create, fee_type: fee_type_params
      end

      it "shows error message" do
        expect(flash[:error]).to eq('Fee Type could not be created.')
      end
    end

    describe "Create Fee Type with standard fee" do
      before do
        fee_type_params = {
          category: 'vehicle', 
          charge_unit: 'per_km',
          name: 'Excess charge per km',
          standard_fee_attributes: { fee: '2.95' }
        }

        signin(admin)
        put :create, fee_type: fee_type_params
      end

      it "should create a new fee type" do
        expect(flash[:success]).to eq('Fee Type created.')
        fee_type = FeeType.find_by(name: 'Excess charge per km')
        expect(fee_type.charge_unit).to eq('per_km')
        expect(fee_type.standard_fee.fee_cents).to eq(295)
      end
    end
  end

  context "Administrator updates Fee Type" do
    before do
      @fee_type = create(:fee_type, category: 'vehicle', charge_unit: 'per_km', name: 'Excess charge per km')
      @fee_type.build_standard_fee(chargeable: @fee_type, fee_type: @fee_type, fee_cents: 295)
      @fee_type.save
    end

    describe "Visit Edit Fee Type page" do
      before do
        signin(admin)
        get :edit, id: @fee_type.id
      end

      it { should respond_with 200 }

      it "displays the edit fee type template" do
        expect(response).to render_template :edit
      end
    end

    describe "Updates Fee Type and Fee" do
      before do
        signin(admin)
        standard_fee_params = { id: @fee_type.standard_fee.id, fee_type_id: @fee_type.id,
                      chargeable_id: @fee_type.id, chargeable_type: 'FeeType', fee: 3.0 }
        fee_type_params = { category: 'consumables', charge_unit: 'per_item', 
                            standard_fee_attributes: standard_fee_params }
        put :update, id: @fee_type.id, fee_type: fee_type_params
      end

      it "updates the fee type and fee" do
        expect(flash[:success]).to eq('Fee Type updated.')
        @fee_type.reload
        expect(@fee_type.category).to eq('consumables')
        expect(@fee_type.charge_unit).to eq('per_item')
        expect(@fee_type.standard_fee.fee_cents).to eq(300)
      end
    end

    describe "Updating Fee Type with errors produces error message" do
      before do
        signin(admin)
        standard_fee_params = { id: @fee_type.standard_fee.id, fee_type_id: @fee_type.id,
                      chargeable_id: @fee_type.id, chargeable_type: 'FeeType', fee: 3.0 }
        fee_type_params = { category: 'consumables', charge_unit: 'per_item', 
                            standard_fee_attributes: standard_fee_params, name: '' }
        put :update, id: @fee_type.id, fee_type: fee_type_params
      end

      it "shows an error message" do
        expect(flash[:error]).to eq('Fee Type could not be updated.')
      end
    end
  end

  context "Administrator views list of Fee Types" do
    before do
      @fee_type = create(:fee_type, category: 'vehicle', charge_unit: 'per_km', name: 'Excess charge per km')
      @fee_type.build_standard_fee(chargeable: @fee_type, fee_type: @fee_type, fee_cents: 295)
      @fee_type.save
    end

    describe "Visit Fee Types Index page" do
      render_views

      before do
        signin(admin)
        get :index
      end

      it { should respond_with 200 }

      it "displays the fee types template" do
        expect(response).to render_template :index
        expect(response.body).to match /Excess charge per km/
        expect(response.body).to match /Vehicle/
      end
    end
  end
end
