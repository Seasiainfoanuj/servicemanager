require 'spec_helper'

describe ContactRoleType do
  describe "validations" do

    let(:contact_role_type) { build(:contact_role_type)}

    it { should validate_uniqueness_of :name }

    it "has a valid factory" do
      expect(contact_role_type).to be_valid
    end

    it "must have a name" do
      contact_role_type.name = ""
      expect(contact_role_type).to be_invalid
    end

  end
end
