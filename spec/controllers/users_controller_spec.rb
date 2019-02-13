require "spec_helper"
require "rack/test"

describe UsersController, type: :controller do
  let(:admin) { FactoryGirl.create(:user, :admin) }

  describe "Administrator views new admin user form" do
    render_views

    before do
      signin(admin)
      get :admin
    end

    it { should respond_with 200 }

    it "presents a new admin page" do
      expect(response).to render_template :admin
      expect(response.body).to match /New Administrator/
    end
  end

  describe "Administrator views new customer form" do
    render_views

    before do
      signin(admin)
      get :customer
    end

    it { should respond_with 200 }

    it "presents a new customer page" do
      expect(response).to render_template :customer
      expect(response.body).to match /New Customer/
    end
  end

  describe "Administrator views new service provider form" do
    render_views

    before do
      signin(admin)
      get :service_provider
    end

    it { should respond_with 200 }

    it "presents a new service provider page" do
      expect(response).to render_template :service_provider
      expect(response.body).to match /New Service Provider/
    end
  end

  describe "Administrator views new supplier form" do
    render_views

    before do
      signin(admin)
      get :supplier
    end

    it { should respond_with 200 }

    it "presents a new supplier page" do
      expect(response).to render_template :supplier
      expect(response.body).to match /New Supplier/
    end
  end

  describe "Administrator views new quote customer form" do
    render_views

    before do
      signin(admin)
      get :quote_customer
    end

    it { should respond_with 200 }

    it "presents a new quote customer page" do
      expect(response).to render_template :quote_customer
      expect(response.body).to match /New Quote Customer/
    end
  end
end

