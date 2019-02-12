require 'spec_helper'

describe SystemError do
  describe "validations" do
    let(:system_error) { build(:system_error) }

    it "has a valid factory" do
      expect(system_error).to be_valid
    end

    it { should validate_presence_of :description }
  end  

  describe "associations" do
    it { should belong_to(:actioned_by) }
  end
end

