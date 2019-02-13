require "spec_helper"
require "rack/test"

describe MasterQuoteItemsController, type: :controller do

  context "Administrator views Master Quote Items" do

    let(:admin) { FactoryGirl.create(:user, :admin) }
    let(:supplier) { FactoryGirl.create(:user, :supplier) }
    let(:body)   { create(:quote_item_type, name: 'Body') }
    let(:engine) { create(:quote_item_type, name: 'Engine') }
    let(:add_on) { create(:quote_item_type, name: 'Add-on') }

    describe "Access the index page" do
      render_views

      before do
        FactoryGirl.create(:master_quote_item, supplier: supplier, quote_item_type: body)
        FactoryGirl.create(:master_quote_item, supplier: supplier, quote_item_type: engine)
        FactoryGirl.create(:master_quote_item, supplier: supplier, quote_item_type: add_on)
        signin(admin)
        get :index
      end
    
      it { should respond_with 200 }

      it "Available Master Quote Items are listed" do
        expect(response).to render_template('index')
        expect(MasterQuoteItem.count).to eq(3)
        expect(response.body).to match /Master Quote Items/im 
      end
    end
  end
end