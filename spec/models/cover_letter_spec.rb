require 'spec_helper'

describe CoverLetter do
  describe "validations" do
    let!(:customer) { create(:user, :customer, email: 'yvonne@me.com', roles: [:contact], client_attributes: { client_type: 'person'}) }
    let!(:manager)  { create(:user, :admin, email: 'eugene@me.com', client_attributes: { client_type: 'person'}) }
    let!(:hire_quote) { create(:hire_quote, customer: customer.client, manager: manager.client)}
    
    it "has a valid factory" do
      expect(build(:cover_letter)).to be_valid
    end

    it { should validate_presence_of :title }
    it { should validate_presence_of :content }
  end

  describe "associations" do
    it { should belong_to(:covering_subject) }
  end
end