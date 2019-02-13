require 'spec_helper'

describe BuildSpecification do
  describe "validations" do
    let(:build) { FactoryGirl.create(:build) }

    before do
      @build_specification = FactoryGirl.build(:build_specification, build: build)
    end

    it "has a valid factory" do
      expect(@build_specification).to be_valid
    end

    it { should respond_to (:paint) }
    it { should respond_to (:other_seating) }
    it { should respond_to (:surveillance_system) }
    it { should respond_to (:comments) }
    it { should respond_to (:lift_up_wheel_arches) }
    it { should validate_presence_of :build_id }

    describe "#swing_type" do
      it "it must be in range" do
        @build_specification.swing_type = 2
        expect(@build_specification).to be_invalid
      end
    end
    
    describe "#heating_source" do
      it "it must be in range" do
        @build_specification.heating_source = 2
        expect(@build_specification).to be_invalid
      end
    end

    describe "#seating_type" do
      it "it must be in range" do
        @build_specification.seating_type = 3
        expect(@build_specification).to be_invalid
      end

      it "requires other seating details when seating type = 'Other'" do
        @build_specification.seating_type = 2
        @build_specification.other_seating = ""
        expect(@build_specification).to be_invalid
      end
    end

    describe "#state_sign" do
      it "it must be in range" do
        @build_specification.state_sign = 4
        expect(@build_specification).to be_invalid
      end
    end
  end

  describe "associations" do
    it { should belong_to(:build) }
  end  
end 
