require 'spec_helper'

describe HireFee do
  describe "validations" do
    let(:fee_type1) { create(:fee_type, name: 'Cleaning Fee') }
    let(:fee_type2) { create(:fee_type, name: 'Excess charge per km') }
    let!(:customer) { create(:user, :customer, email: 'yvonne@me.com', client_attributes: { client_type: 'person'}) }
    let!(:manager)  { create(:user, :admin, email: 'eugene@me.com', client_attributes: { client_type: 'person'}) }
    let!(:hire_quote) { create(:hire_quote, customer: customer.client, manager: manager.client) }
    let!(:vehicle_make) { VehicleMake.first || create(:vehicle_make) }
    let!(:vehicle_model) { create(:vehicle_model, make: vehicle_make) }
    let(:hire_quote_vehicle) { create(:hire_quote_vehicle, hire_quote: hire_quote, vehicle_model: vehicle_model) }

    before do
      @hire_fee = build(:hire_fee, fee_type: fee_type1, chargeable: hire_quote_vehicle)
    end

    subject { @hire_fee }

    it "has a valid factory" do
      expect(@hire_fee).to be_valid
    end

    it { should validate_presence_of :fee_type_id }

    describe "uniqueness" do
      before do
        @hire_fee.save
      end
      
      it "must be unique on Fee type and Chargeable owner" do
        hire_fee2 = @hire_fee.dup
        expect(hire_fee2).to be_invalid
        hire_fee2.fee_type = fee_type2
        expect(hire_fee2).to be_valid
      end
    end
  end

  describe "associations" do
    it { should belong_to(:fee_type) }
    it { should belong_to(:chargeable) }
  end

end
