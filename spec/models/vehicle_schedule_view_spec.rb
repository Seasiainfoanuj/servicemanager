require 'spec_helper'

describe VehicleScheduleView do
  describe "validations" do
    it "has a valid factory" do
      expect(build(:vehicle_schedule_view)).to be_valid
    end
  end

  describe "associations" do
    it { should belong_to(:vehicle) }
    it { should belong_to(:schedule_view) }
  end
end
