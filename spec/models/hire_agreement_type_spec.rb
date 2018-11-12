require 'spec_helper'

describe HireAgreementType do
  describe "validations" do
    it "has a valid factory" do
      expect(build(:vehicle)).to be_valid
    end

    it "is valid with name, damage_recovery_fee and fuel_service_fee" do
      hire_agreement_type = create(:hire_agreement_type,
        name: Faker::Lorem.word,
        damage_recovery_fee: Faker::Number.number(2),
        fuel_service_fee: Faker::Number.number(2)
      )
      expect(hire_agreement_type).to be_valid
    end
  end

  describe "associations" do
    it { should have_many(:hire_agreements) }
    it { should have_many(:uploads).class_name('HireAgreementTypeUpload') }

    it { should accept_nested_attributes_for(:uploads).allow_destroy(true) }
  end
end
