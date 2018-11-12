require 'spec_helper'

describe ScheduleView do
  describe "validations" do
    it "has a valid factory" do
      expect(build(:schedule_view)).to be_valid
    end

    it { should validate_presence_of :name }
    it { should validate_uniqueness_of :name }
  end

  describe "associations" do
    it { should have_many(:vehicle_schedule_views).dependent(:destroy) }
    it { should have_many(:vehicles).through(:vehicle_schedule_views) }

    it { should accept_nested_attributes_for(:vehicle_schedule_views).allow_destroy(true) }
  end
end
