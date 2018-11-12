require "spec_helper"
require "rack/test"

describe QuoteItemTypesController, type: :controller do

  context "Administrator creates Quote Item Type" do
    let(:admin) { FactoryGirl.create(:user, :admin) }

    describe "Valid create parameters produce success message" do
      before do
        quote_item_type_params = {
          name: 'Body', 
          sort_order: 2,
          allow_many_per_quote: true
        }

        signin(admin)
        put :create, quote_item_type: quote_item_type_params
      end

      it "should create a new quote item type" do
        expect(flash[:success]).to eq('Quote Item Type created.')
        expect(QuoteItemType.find_by(name: 'Body').sort_order).to eq(2)
      end
    end

    describe "Invalid create parameters produce error message" do
      before do
        quote_item_type_params = {
          name: '', 
          sort_order: 1,
          allow_many_per_quote: true
        }

        signin(admin)
        put :create, quote_item_type: quote_item_type_params
      end

      it "should not create a new quote item type" do
        expect(flash[:error]).to eq('Quote Item Type could not be created.')
      end
    end
  end

  context "Administrator updates Quote Item Type" do
    let(:admin) { FactoryGirl.create(:user, :admin) }
    let(:quote_item_type) { QuoteItemType.create(name: 'Accessory', sort_order: 1, allow_many_per_quote: true) }

    describe "Valid update parameters produce success message" do
      before do
        quote_item_type_params = {
          name: 'Accessory', 
          sort_order: 2,
          allow_many_per_quote: true
        }

        signin(admin)
        put :update, id: quote_item_type.id, quote_item_type: quote_item_type_params
      end

      it "should update the quote item type" do
        expect(flash[:success]).to eq('Quote Item Type updated.')
        expect(quote_item_type.reload.sort_order).to eq(2)
      end
    end

    describe "Invalid update parameters produce error message" do
      before do
        quote_item_type_params = {
          name: '', 
          sort_order: 1,
          allow_many_per_quote: true
        }

        signin(admin)
        put :update, id: quote_item_type.id, quote_item_type: quote_item_type_params
      end

      it "should not update the quote item type" do
        expect(flash[:error]).to eq('Quote Item Type could not be updated.')
      end
    end
  end

  context "Administrator views list of Quote Item Types" do
    render_views
    
    let(:admin) { FactoryGirl.create(:user, :admin) }
    let(:quote_item_type) { QuoteItemType.create(name: 'Accessory', sort_order: 1, allow_many_per_quote: true) }

    describe "Access the index page" do
      before do
        signin(admin)
        get :index
      end
    
      it { should respond_with 200 }

      it "Available QuoteItemTypes are listed" do
        expect(response).to render_template :index
        expect(response.body).to match /Quote Item Types/im 
        # Cannot test more because of datatables:
        # http://everydayrails.com/2012/04/07/testing-series-rspec-controllers.html
      end
    end
  end  
end