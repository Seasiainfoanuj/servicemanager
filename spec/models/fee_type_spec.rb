require 'spec_helper'

describe FeeType do
  describe "validations" do

    let(:fee_type) { build(:fee_type)}

    it { should validate_uniqueness_of :name }
    it { should validate_presence_of :name }
    it { should validate_presence_of :charge_unit }

    it "has a valid factory" do
      expect(fee_type).to be_valid
    end

    describe "#name" do
      before do 
        @invalid_names = ["", "abcd", "a" * 41]
      end  

      it "must have a valid length" do
        @invalid_names.each do |name|
          fee_type.name = name
          expect(fee_type).to be_invalid
        end
      end
    end

    describe "#charge_unit" do
      before do
        @invalid_charge_units = ["", "surprise"]
      end

      it "must contain a valid charge_unit" do
        @invalid_charge_units.each do |unit|
          fee_type.charge_unit = unit
          expect(fee_type).to be_invalid
        end
      end
    end

    describe "#categories" do
      before do
        @invalid_categories = ["", "entertainment"]
      end

      it "must contain a valid categories" do
        @invalid_categories.each do |cat|
          fee_type.category = cat
          expect(fee_type).to be_invalid
        end
      end
    end

    describe "#standard_fee" do
      before do
        fee_type.save
        fee_type.reload
        @standard_fee = HireFee.new( fee_type_id: fee_type.id, fee_cents: 2499 )
      end

      it "may contain a standard fee" do
        fee_type.build_standard_fee( @standard_fee.attributes )
        expect(fee_type).to be_valid
        fee_type.save
        expect(fee_type.standard_fee.fee_type_id).to eq(fee_type.id)
        expect(fee_type.standard_fee.chargeable_id).to eq(fee_type.id)
        expect(fee_type.standard_fee.chargeable_type).to eq('FeeType')
        expect(fee_type.standard_fee.fee_cents).to eq(2499)
      end
    end
  end

  describe "associations" do
    it { should have_one(:standard_fee) }
    it { should accept_nested_attributes_for(:standard_fee).allow_destroy(true) }
  end  

end