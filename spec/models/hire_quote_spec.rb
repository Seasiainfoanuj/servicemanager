require "spec_helper"
describe HireQuote do
  describe "validations" do

    let!(:customer) { create(:user, :customer, email: 'yvonne@me.com', roles: [:contact], client_attributes: { client_type: 'person'}) }
    let!(:manager)  { create(:user, :admin, email: 'eugene@me.com', client_attributes: { client_type: 'person'}) }

    before do
      @hire_quote = build(:hire_quote, customer: customer.client,
                                         manager: manager.client)
    end

    subject { @hire_quote }

    it "has a valid factory" do
      expect(@hire_quote).to be_valid
    end

    it { should respond_to(:start_date) }
    it { should respond_to(:status_date) }
    it { should respond_to(:last_viewed) }
    it { should respond_to(:tags) }
    it { should respond_to(:uid) }
    it { should respond_to(:reference) }
    it { should respond_to(:authorised_contact) }
    it { should respond_to(:quoted_date) }
    it { should validate_presence_of :version }
    it { should validate_presence_of :manager_id }

    describe "Each HireQuote must be unique on uid + version number" do
      before do
        @hire_quote.save
        @hire_quote2 = @hire_quote.dup
      end

      it "should not allow same uid and version number" do
        expect(@hire_quote2).to be_invalid
      end

      it "should accept the same uid, provided the version is different" do
        @hire_quote2.version = 2
        expect(@hire_quote2).to be_valid
      end     
    end

    describe "#to_param" do
      before do
        @hire_quote.save
      end
      
      it "should paramerise the quote" do
        expect(@hire_quote.to_param).to eq(@hire_quote.reference.downcase)
      end  
    end

    describe "#admin_may_perform_action?" do
      before do
        @valid_actions = [{action: :update, status: 'draft'},
                          {action: :send_quote, status: 'sent'},
                          {action: :cancel, status: 'draft'},
                          {action: :create_amendment, status: 'sent'},
                          {action: :update_hire_addon, status: 'draft'}]

        @invalid_actions = [{action: :update, status: 'sent'},
                          {action: :create_amendment, status: 'draft'},
                          {action: :delete_hire_addon, status: 'accepted'},
                          {action: :send_quote, status: 'accepted'},
                          {action: :new_action, status: 'draft'}]
        allow_any_instance_of(HireQuote).to receive(:has_missing_details?).and_return(false)
      end

      it "allows an admin to perform selected actions" do
        @valid_actions.each do |valid_access|
          @hire_quote.status = valid_access[:status]
          expect(@hire_quote.admin_may_perform_action?(valid_access[:action])).to eq(true)
        end
      end

      it "prevents an admin from performing unauthorised actions" do
        @invalid_actions.each do |invalid_access|
          @hire_quote.status = invalid_access[:status]
          expect(@hire_quote.admin_may_perform_action?(invalid_access[:action])).to eq(false)
        end
      end
    end

    describe "#customer_may_perform_action?" do
      before do
        @valid_actions = [{action: :accept_quote, status: 'sent'}]
 
        @invalid_actions = [{action: :update, status: 'sent'},
                            {action: :view, status: 'draft'},
                            {action: :accept_quote, status: 'accepted'}]
      end

      it "allows a customer to perform selected actions" do
        @valid_actions.each do |valid_access|
          @hire_quote.status = valid_access[:status]
          expect(@hire_quote.customer_may_perform_action?(valid_access[:action])).to eq(true)
        end
      end

      it "prevents a customer from performing unauthorised actions" do
        @invalid_actions.each do |invalid_access|
          @hire_quote.status = invalid_access[:status]
          expect(@hire_quote.customer_may_perform_action?(invalid_access[:action])).to eq(false)
        end
      end
    end

    describe "#perform_action(:send_quote)" do
      let(:enquiry) { create(:enquiry, user: customer, manager: manager) }

      before do
        create(:hire_enquiry, enquiry: @enquiry)
        @hire_quote.enquiry = enquiry
        @hire_quote.save
        @freezed_time = Time.new(2016, 9, 15, 16, 30, 45)
        Timecop.freeze(@freezed_time)
        @response = @hire_quote.perform_action(:send_quote)
        @hire_quote.reload
        customer.reload
        enquiry.reload
      end

      after do
        Timecop.return
      end

      it "updates the quote, customer and enquiry when a quote is sent" do
        expect(@response).to eq(true)
        expect(@hire_quote.status).to eq('sent')
        expect(@hire_quote.status_date.day).to eq(15)
        expect(customer.roles.count).to eq(1)
        expect(customer.roles.include?(:quote_customer)).to eq(true)
        expect(enquiry.status).to eq('quoted')
      end
    end

    describe "#perform_action(:accept_quote)" do
      before do
        customer.update(roles: [:quote_customer])
        @hire_quote.save
        @freezed_time = Time.new(2016, 9, 15, 16, 30, 45)
        Timecop.freeze(@freezed_time)
        @response = @hire_quote.perform_action(:accept_quote)
        @hire_quote.reload
        customer.reload
      end

      after do
        Timecop.return
      end

      it "updates the quote and customer when a quote is accepted" do
        expect(@response).to eq(true)
        expect(@hire_quote.status).to eq('accepted')
        expect(@hire_quote.status_date.day).to eq(15)
        expect(customer.roles.count).to eq(1)
        expect(customer.roles.include?(:customer)).to eq(true)
      end
    end

    describe "#perform_action(:view)" do
      before do
        customer.update(roles: [:quote_customer])
        @hire_quote.save
        @hire_quote.update(status: 'sent')
        @freezed_time = Time.new(2016, 9, 15, 16, 30, 45)
        Timecop.freeze(@freezed_time)
        @response = @hire_quote.perform_action(:view)
        @hire_quote.reload
      end

      after do
        Timecop.return
      end

      it "updates the last_viewed date when the customer views the quote" do
        expect(@response).to eq(true)
        expect(@hire_quote.last_viewed.hour).to eq(16)
        expect(@hire_quote.last_viewed.day).to eq(15)
        expect(@hire_quote.last_viewed.month).to eq(9)
      end
    end

    describe "#perform_action(:request_changes)" do
      before do
        customer.update(roles: [:quote_customer])
        @hire_quote.save
        @hire_quote.update(status: 'sent')
        @freezed_time = Time.new(2016, 9, 15, 16, 30, 45)
        Timecop.freeze(@freezed_time)
        @response = @hire_quote.perform_action(:request_changes)
        @hire_quote.reload
      end

      after do
        Timecop.return
      end

      it "updates the status_date when the customer requests changes to the quote" do
        expect(@response).to eq(true)
        expect(@hire_quote.status_date.hour).to eq(16)
        expect(@hire_quote.status_date.day).to eq(15)
        expect(@hire_quote.status_date.month).to eq(9)
        expect(@hire_quote.status).to eq('changes requested')
      end
    end

    describe "#perform_action(:cancel_quote)" do
      before do
        @hire_quote.save
        @hire_quote.update(status: 'sent')
        @freezed_time = Time.new(2016, 9, 15, 16, 30, 45)
        Timecop.freeze(@freezed_time)
        @response = @hire_quote.perform_action(:cancel_quote)
        @hire_quote.reload
      end

      after do
        Timecop.return
      end

      it "updates the status_date when the customer requests changes to the quote" do
        expect(@response).to eq(true)
        expect(@hire_quote.status_date.hour).to eq(16)
        expect(@hire_quote.status_date.day).to eq(15)
        expect(@hire_quote.status_date.month).to eq(9)
        expect(@hire_quote.status).to eq('cancelled')
      end
    end

    describe "#authorised_contact" do
      before do
        @company = create(:company, client_attributes: { client_type: 'company'})
        @user = create(:user, email: 'contact@me.com', representing_company: @company)
      end

      it "provides the user when the client is a person" do
        @hire_quote.save
        expect(@hire_quote.authorised_contact).to eq(customer)
      end

      it "provides the preferred contact when the client is a company" do
        @hire_quote.customer = @company.client
        @hire_quote.save
        expect(@hire_quote.authorised_contact).to eq(@user)
      end
    end

    describe "#quoting_company" do
      before do
        create(:invoice_company, name: 'Bus 4x4 Hire Pty. Ltd.', slug: 'bus_hire')
      end

      it "Always regards Bus 4x4 Hire Pty. Ltd. as the company that provides Hire Quotes" do
        expect(@hire_quote.quoting_company.name).to eq(BUS4X4_HIRE_COMPANY_NAME)
      end
    end

    describe "#reference" do
      before do
        @hire_quote.save
      end

      it "formats the Hire Quote Reference as uid-version" do
        puts "Reference: #{@hire_quote.reference}"
        expect(@hire_quote.reference).to eq("#{@hire_quote.uid}-#{@hire_quote.version}")
      end
    end

    describe "#has_missing_details?" do
      before do
        @hire_quote.build_cover_letter(title: 'Your special quote', content: 'Bla bla bla')
        @hire_quote.save
      end

      it "has missing details when the quote has no vehicles" do
        expect(@hire_quote.has_missing_details?).to eq(true) 
      end

      it "has missing details if one of the vehicles has no daily rate" do
        create_hire_quote_vehicle
        expect(@hire_quote.has_missing_details?).to eq(true) 
      end

      it "has no missing details when all component details are present" do
        create_hire_quote_vehicle_with_fees
        expect(@hire_quote.has_missing_details?).to eq(false) 
      end
    end

    describe "#self.get_new_version" do
      before do
        @hire_quote.save
      end

      it "finds the next version number for a given uid" do
        expect(HireQuote.get_new_version(@hire_quote.uid)).to eq(2)
      end
    end

    describe "#self.find_latest_quote_by_uid(uid)" do
      before do
        @hire_quote.save
        @hire_quote2 = @hire_quote.dup
        @hire_quote2.version = 2
        @hire_quote2.save
      end

      it "finds the latest version number for the hire quote uid" do
        expect(HireQuote.find_latest_quote_by_uid(@hire_quote.uid)).to eq(@hire_quote2)
      end
    end

    context "#initialise_authorised_contact" do
      describe "when the customer is a person" do
        before do
          @hire_quote.save
          @hire_quote.reload
        end

        it "assigns a authorised_contact when the quote is created" do
          expect(@hire_quote.authorised_contact).to eq(customer)
        end
      end

      describe "when the customer is a company" do
        before do
          @company = create(:company, default_contact: nil, client_attributes: {client_type: "company"})
          @contact1 = create(:user, :contact, email: 'surprise@me.com', representing_company: @company, client_attributes: {client_type: "person"})
          @contact2 = create(:user, :contact, email: 'wondering@me.com', representing_company: @company, client_attributes: {client_type: "person"})
        end

        it "assigns the first contact when the company has no default contact" do
          @hire_quote2 = create(:hire_quote, customer: @company.client, manager: manager.client)
          expect(@hire_quote2.authorised_contact).to eq(@contact1)
        end

        it "assigns the company's default contact when such a contact exists" do
          @company.update(default_contact: @contact2)
          @hire_quote2 = create(:hire_quote, customer: @company.client, manager: manager.client)
          expect(@hire_quote2.authorised_contact).to eq(@contact2)
        end
      end
    end

    describe "#valid_customer" do
      before do
        @company = create(:company, client_attributes: {client_type: "company"})
        @hire_quote.customer = @company.client
      end

      it "considers a company without contacts an invalid customer" do
        expect { @hire_quote.save! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "#reassign_authorised_contact" do
      describe "when new customer is a person" do
        before do
          @customer2 = create(:user, :customer, email: 'bernard@me.com', roles: [:contact], client_attributes: { client_type: 'person'})
          @contact = create(:user, :customer, email: 'emily@me.com', roles: [:contact], client_attributes: { client_type: 'person'})
          @hire_quote.customer = @customer2.client
          @hire_quote.save
          @hire_quote.update(authorised_contact: @contact)
          @hire_quote.reassign_authorised_contact
        end

        it "assigns the customer person as the new authorised contact" do
          expect(@hire_quote.authorised_contact).to eq(@customer2)
        end
      end

      describe "when new customer is a company" do
        before do
          @customer2 = create(:company, client_attributes: {client_type: "company"})
          @contact2 = create(:user, :contact, email: 'unexpected@me.com', representing_company: @customer2, client_attributes: {client_type: "company"})
          @hire_quote.customer = @customer2.client
          @hire_quote.save
          @hire_quote.reassign_authorised_contact
        end

        it "assigns the contact of the customer company as the new authorised contact" do
          expect(@hire_quote.authorised_contact).to eq(@contact2)
        end
      end
    end
  end

  describe "associations" do
    it { should belong_to(:manager).class_name("Client") }
    it { should belong_to(:customer).class_name("Client") }
    it { should belong_to(:authorised_contact).class_name("User") }
    it { should belong_to(:enquiry) }
    it { should have_many(:vehicles).class_name("HireQuoteVehicle") }
    it { should have_one(:cover_letter) }

  end

  private

    def create_hire_quote_vehicle
      vehicle_make = create(:vehicle_make, name: 'Isuzu')
      vehicle_model = create(:vehicle_model, make: vehicle_make, name: 'LX400', daily_rate_cents: 55000)
      @hire_quote_vehicle = create(:hire_quote_vehicle, hire_quote: @hire_quote, vehicle_model: vehicle_model, start_date: Date.new(2016,12,1), end_date: Date.new(2017,12,1))
    end

    def create_hire_quote_vehicle_with_fees
      create_hire_quote_vehicle
      fee_type_1 = create(:fee_type, name: 'Cleaning Fee')
      fee1 = create(:hire_fee, fee_type: fee_type_1, chargeable: fee_type_1)
      fee_type_2 = create(:fee_type, name: 'Flag Replacement')
      fee2 = create(:hire_fee, fee_type: fee_type_2, chargeable: fee_type_2)
      @hire_quote_vehicle.update(fees_attributes: { 
      "0" => {fee_type_id: fee_type_1.id, fee_cents: 14955, chargeable_type: 'HireQuoteVehicle', 
              chargeable_id: @hire_quote_vehicle.id}, 
      "1" => {fee_type_id: fee_type_2.id, fee_cents: 11955, chargeable_type: 'HireQuoteVehicle', 
              chargeable_id: @hire_quote_vehicle.id}})
    end

end    
