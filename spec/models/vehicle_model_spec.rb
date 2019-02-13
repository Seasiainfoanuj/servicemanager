require "spec_helper"

describe VehicleModel do
  describe "validations" do
    let(:vehicle_make) { create(:vehicle_make, name: 'Toyota') }

    before do
      @vehicle_model = build(:vehicle_model, make: vehicle_make, year: 2012, name: 'Sprinter')
    end

    it "has a valid factory" do
      expect(build(:vehicle_model)).to be_valid
    end

    it { should validate_presence_of :vehicle_make_id }
    it { should validate_presence_of :name }
    it { should respond_to :number_of_seats }
    it { should respond_to :daily_rate_cents }
    it { should respond_to :license_type }

    it "returns full_name as string" do
      expect(@vehicle_model.full_name).to eq "Toyota Sprinter"
    end

    # describe "Test for uniqueness" do
    #   before { @vehicle_model.save }

    #   it "must have unique Year Make Model" do
    #     model2 = @vehicle_model.dup
    #     expect { model2.save! }.to raise_error
    #   end
    # end

    describe "hire add-ons" do
      before do
        @vehicle_model.save
        @addon1 = create(:hire_addon, model_name: 'model-a')
        @addon2 = create(:hire_addon, model_name: 'model-b')
      end

      it "should tell when the vehicle model has no add-ons" do
        expect(@vehicle_model.hire_addons).to eq(HireAddon.none)
      end

      it "should create and report on hire add-ons" do
        @vehicle_model.hire_addons << @addon1
        expect(@vehicle_model.hire_addons.count).to eq(1)
        expect(@vehicle_model.hire_addons.first).to eq(@addon1)
        expect(@addon1.vehicle_models.first).to eq(@vehicle_model)
      end

      it "should remove and report on hire add-ons" do
        @vehicle_model.hire_addons << @addon1
        @vehicle_model.hire_addons << @addon2
        expect(@vehicle_model.hire_addons.count).to eq(2)
        @vehicle_model.hire_addons.delete(@addon1)
        expect(@vehicle_model.hire_addons.count).to eq(1)
        expect(@addon2.vehicle_models.first).to eq(@vehicle_model)
      end
    end

    describe "hire product types" do
      before do
        @vehicle_model.save
        @prod_type_1 = create(:hire_product_type, name: 'School bus')
        @prod_type_2 = create(:hire_product_type, name: 'Tour bus')
      end

      it "should tell when the vehicle model has no hire product types" do
        expect(@vehicle_model.hire_product_types).to eq(HireProductType.none)
      end

      it "should create and report on hire product types" do
        @vehicle_model.hire_product_types << @prod_type_1
        expect(@vehicle_model.hire_product_types.count).to eq(1)
        expect(@vehicle_model.hire_product_types.first).to eq(@prod_type_1)
        expect(@prod_type_1.vehicle_models.first).to eq(@vehicle_model)
      end

      it "should remove and report on hire product types" do
        @vehicle_model.hire_product_types << @prod_type_1
        @vehicle_model.hire_product_types << @prod_type_2
        expect(@vehicle_model.hire_product_types.count).to eq(2)
        @vehicle_model.hire_product_types.delete(@prod_type_1)
        expect(@vehicle_model.hire_product_types.count).to eq(1)
        expect(@prod_type_2.vehicle_models.first).to eq(@vehicle_model)
      end
    end

  end

  describe "associations" do
    it { should belong_to(:make).class_name('VehicleMake').with_foreign_key('vehicle_make_id') }
    it { should have_many(:stocks) }
    it { should have_many(:vehicles) }
    it { should have_many(:images) }
    it { should have_and_belong_to_many(:hire_addons) }
    it { should have_and_belong_to_many(:hire_product_types) }
    it { should have_many(:quoted_vehicles).class_name('HireQuoteVehicle') }
    it { should have_many(:fees) }
  end
end