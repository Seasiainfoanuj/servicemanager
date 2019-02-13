require 'spec_helper'

describe NewsletterSubscription do
  describe "validations" do

    before do
      @newsletter_subscription = build(:newsletter_subscription)
    end

    it "has a valid factory" do
      expect(@newsletter_subscription).to be_valid
    end

    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }
    it { should validate_presence_of :email }
    it { should validate_presence_of :subscription_origin }
  end
end
