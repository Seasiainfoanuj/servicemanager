require 'spec_helper'

describe Client do
  describe "validations" do
    before do
      @client = FactoryGirl.build(:client, client_type: 'person')
    end

    subject { @client }

    it "has a valid factory" do
      expect(@client).to be_valid
    end

    it { should validate_uniqueness_of :reference_number }
    it { should validate_presence_of :client_type }

    it { should respond_to :user }
    it { should respond_to :company }
    it { should respond_to :archived_at }

    describe "#person?" do
      it "recognises a person by it's client_type" do
        @client.client_type = "person"
        expect(@client.person?).to eq(true)
      end
    end

    describe "#company?" do
      it "recognises a company by it's client_type" do
        @client.client_type = "company"
        expect(@client.company?).to eq(true)
      end
    end

    describe "#employee?" do
      before do
        @employer = FactoryGirl.create(:invoice_company, abn: '16140752290')
        @user = FactoryGirl.create(:user, :admin, employer: @employer,
          client_attributes: {client_type: "person"})
        @client = @user.client
      end

      it "recognises an employee by it's admin role" do
        expect(@client.employee?).to eq(true)
      end

      it "presents the user's employer as the client's employer" do
        expect(@client.employer).to eq(@employer)
        expect(@client.user_company).to eq(@employer)
        expect(@client.name).to eq(@user.name)
      end
    end

    describe "#name" do
      before do
        @company = FactoryGirl.build(:company, name: 'ABC Manufacturing Ltd',
           abn: '36612323850', client_attributes: {client_type: "company"})
        @company.save
        @user = FactoryGirl.create(:user, :customer,  company: @company, 
          client_attributes: {client_type: 'person'})
        @company_client = @company.client
        @user_client = @user.client
      end

      it "presents the user's company name as the client's name" do
        expect(@user_client.name).to eq(@user.name)
        expect(@company_client.name).to eq(@company.name)
      end
    end

  end
end