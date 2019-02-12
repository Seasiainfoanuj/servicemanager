require "spec_helper"
describe HireAddon do
  describe "validations" do

    before do
      @hire_addon = build(:hire_addon)
    end

    subject { @hire_addon }

    it "has a valid factory" do
      expect(@hire_addon).to be_valid
    end

    it { should respond_to(:hire_price_cents) }

    it { should validate_presence_of :addon_type }
    it { should validate_presence_of :model_name }
    it { should validate_presence_of :billing_frequency }

    it "monetize matcher matches cost without a '_cents' suffix by default" do
      expect(build(:hire_addon)).to monetize(:hire_price_cents)
    end

    describe "#billing_frequency" do
      it "should allow only valid instances" do
        ['once-off', 'daily', 'weekly', 'monthly'].each do |frequency|
          @hire_addon.billing_frequency = frequency
          expect(@hire_addon).to be_valid
        end  
      end

      it "should reject invalid instances" do
        ['', 'yearly'].each do |frequency|
          @hire_addon.billing_frequency = frequency
          expect(@hire_addon).to be_invalid
        end  
      end
    end

    describe "#addon_type" do
      it "should allow only valid instances" do
        ['Seat Sense', 'GPS'].each do |type|
          @hire_addon.addon_type = type
          expect(@hire_addon).to be_valid
        end  
      end

      it "should reject invalid instances" do
        ['', 'Mag wheels'].each do |type|
          @hire_addon.addon_type = type
          expect(@hire_addon).to be_invalid
        end  
      end
    end

    describe "#model_name" do
      before do
        @hire_addon.addon_type = "GPS"
        @hire_addon.model_name = "XT400"
        @hire_addon.save
      end

      it "must be unique within addon_type" do
        addon2 = @hire_addon.dup
        expect(addon2).to be_invalid
      end

      it "must be unique regardless of case" do
        addon2 = @hire_addon.dup
        addon2.model_name = "xt400"
        expect(addon2).to be_invalid
      end
    end

    describe "#name" do
      it "correctly formats the add-on name" do
        @hire_addon.addon_type = "GPS"
        @hire_addon.model_name = "XT400"
        expect(@hire_addon.name).to eq("GPS XT400")
      end
    end
  end

  describe "associations" do
    it { should have_and_belong_to_many(:vehicle_models) }
    it { should have_many(:hire_quote_addons) }
  end
end
