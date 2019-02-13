require "spec_helper"

describe CustomerMembership do
  describe "validations" do

    let(:user) { create(:user, :quote_customer) }
    let(:company) { create(:company) }

    before do
      @customer_membership = build(:customer_membership, 
                                        quoted_by_company: company, 
                                        quoted_customer: user)
    end

    subject { @customer_membership }

    it "has a valid factory" do
      expect(@customer_membership).to be_valid
    end

    it { should respond_to(:xero_identifier) }

    it "should allow a user to reference it's memberships" do
      @customer_membership.save!
      expect(user.customer_memberships.first).to eq(@customer_membership)
      expect(company.customer_memberships.first).to eq(@customer_membership)
    end
  end
end