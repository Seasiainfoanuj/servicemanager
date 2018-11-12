require 'spec_helper'

describe HireProductType do
  describe "validations" do

    let(:hire_product_type) { build(:hire_product_type)}

    it { should validate_uniqueness_of :name }

    it "has a valid factory" do
      expect(hire_product_type).to be_valid
    end

    it "must have a name" do
      hire_product_type.name = ""
      expect(hire_product_type).to be_invalid
    end

  end

  describe "associations" do
    it { should have_and_belong_to_many(:vehicle_models) }
  end  
end
