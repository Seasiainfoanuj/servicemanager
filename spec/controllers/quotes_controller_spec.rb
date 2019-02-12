require "spec_helper"
require "rack/test"

describe QuotesController, type: :controller do

  context "Administrator updates Quote" do

    let!(:no_tax) { FactoryGirl.create(:tax, name: "", rate: 0.1) }
    let!(:tax)    { FactoryGirl.create(:tax, name: "GST", rate: 0) }
    let(:admin) { FactoryGirl.create(:user, :admin) }

    describe "Valid update produces success message" do
      before do
        @quote = FactoryGirl.create(:quote, number: 2000, manager: admin, items: [FactoryGirl.build(:quote_item)])
        new_params = { number: @quote.number, terms: 'Modified terms' }
        signin(admin)
        put :update, id: 2000, :quote => new_params
      end

      it "updates" do
        expect(response).to redirect_to('/quotes/2000')
        expect(flash[:success]).to eq('Quote updated.')
        @quote.reload
        expect(@quote.terms).to eq('Modified terms')
      end
    end

    describe "Quote updated with invalid item type receives 'Other' Item Type" do
      render_views

      before do
        FactoryGirl.create(:quote_item_type, name: 'Other')
        @quote = FactoryGirl.create(:quote, number: 2000, manager: admin, items: [FactoryGirl.build(:quote_item)])
        new_item_params = FactoryGirl.attributes_for(:quote_item, quote_item_type_id: nil, description: 'New Description', tax: no_tax)
        new_params = { number: @quote.number, items_attributes: {"0" => new_item_params } }
        signin(admin)
        put :update, id: 2000, :quote => new_params
      end

      it "should not update" do
        # expect(subject).to render_template(:show)
        expect(response).to redirect_to('/quotes/2000')
        expect(flash[:success]).to eq('Quote updated.')
      end
    end
  end

  context "Customer accepts Quote" do
    let(:customer) { FactoryGirl.create(:user, :customer) }

    describe "Customer decides to proceed with order" do
      before do
        @quote = FactoryGirl.create(:quote, number: 2000, customer: customer)
        signin(customer)
        # http://stackoverflow.com/questions/6352333/rails-rspec-testing-delayed-job-mails
        # Alternative:
        # mock_delay = double('mock_delay').as_null_object
        # MyClass.any_instance.stub(:delay).and_return(mock_delay)
        # mock_delay.should_receive(:my_delayed_method)
        Delayed::Worker.delay_jobs = false
        get :accept, quote_id: 2000
      end

      after do
        Delayed::Worker.delay_jobs = true
      end

      it "changes quote status to accepted" do
        expect(response).to redirect_to('/quotes/2000?referrer=accepted')
        expect(flash[:success]).to eq('Quote accepted.')
        @quote.reload
        expect(@quote.status).to eq('accepted')
      end
    end
  end

  context "Customer views their own accepted quote" do
    let(:customer) { FactoryGirl.create(:user, :customer) }

    describe "Customer decides to proceed with order" do
      before do
        @quote = FactoryGirl.create(:quote, number: 2000, customer: customer, status: "accepted")
        signin(customer)
        get :show, id: @quote.number
      end

      it { should respond_with 200 }

      it "presents the show page" do
        expect(response).to render_template('show')
      end
    end
  end
end


