require "spec_helper"

describe VehicleMake do
  describe "validations" do
    it "has a valid factory" do
      expect(build(:vehicle_make)).to be_valid
    end

    it "is valid with name" do
      make = build(:vehicle_make, name: Faker::Lorem.word)
      expect(make).to be_valid
    end
  end

  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }

  describe "#name" do
    before do
      @invalid_names = ["A", "f" * 51]
      @vehicle_make = build(:vehicle_make)
    end

    it "Should not accept invalid names" do
      @invalid_names.each do |invalid_name|
        @vehicle_make.name = invalid_name
        expect(@vehicle_make).to be_invalid
      end
    end
  end

  describe "associations" do
    it { should have_many(:models).class_name('VehicleModel') }
  end
end