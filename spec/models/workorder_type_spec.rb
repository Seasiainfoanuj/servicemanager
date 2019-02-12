require 'spec_helper'

describe WorkorderType do
  describe "validations" do
    it "has a valid factory" do
      expect(build(:workorder_type)).to be_valid
    end
  end

  describe "associations" do
    it { should have_many(:workorders) }
    it { should have_many(:workorder_type_uploads) }
  end
end
