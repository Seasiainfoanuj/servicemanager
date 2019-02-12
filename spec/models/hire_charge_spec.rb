require 'spec_helper'

describe HireCharge do
  describe "validations" do
    it "has a valid factory" do
      expect(build(:hire_charge)).to be_valid
    end

    it { should validate_presence_of :hire_agreement_id }
    it { should validate_presence_of :name }
    it { should validate_presence_of :amount_cents }
    it { should validate_presence_of :calculation_method }
    it { should validate_presence_of :quantity }

    it "monetize matcher matches amount without a '_cents' suffix by default" do
      expect(build(:hire_charge)).to monetize(:amount_cents)
    end
  end

  describe "associations" do
    it { should belong_to(:hire_agreement) }
    it { should belong_to(:tax) }
  end
end
