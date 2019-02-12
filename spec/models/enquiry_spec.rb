require 'spec_helper'

describe Enquiry do
  describe "validations" do
    let(:enquiry) { build(:enquiry, uid: 'ABC def 1') }

    it "has a valid factory" do
      expect(enquiry).to be_valid
    end

    it { should validate_presence_of :enquiry_type_id }
    it { should respond_to(:subscribe_to_newsletter) }

    it "should a valid resource name" do
      expect(enquiry.resource_name).to eq('Enquiry abc-def-1')
    end

    describe "#first_name" do
      it "is mandatory" do
        enquiry.first_name = ""
        expect(enquiry).to be_invalid
      end

      it "must have a valid length" do
        ['a', 'a'*41].each do |name|
          enquiry.first_name = name
          expect(enquiry).to be_invalid
        end
      end
    end

    describe "#last_name" do
      it "is mandatory" do
        enquiry.last_name = ""
        expect(enquiry).to be_invalid
      end

      it "must have a valid length" do
        ['a', 'a'*41].each do |name|
          enquiry.last_name = name
          expect(enquiry).to be_invalid
        end
      end
    end

    describe "#email" do
      it "must be valid" do
        [nil, '', 'wrong.format'].each do |email|
          enquiry.email = email
          expect(enquiry).to be_invalid
        end  
      end  
    end

    describe "#phone" do
      it "must have a valid length" do
        ['1'*7, '1'*21].each do |phone|
          enquiry.phone = phone
          expect(enquiry).to be_invalid
        end
      end

      it "must be optional" do
        enquiry.phone = nil
        expect(enquiry).to be_valid
      end
    end

    describe "#to_param" do
      it "returns parameterized uid" do
        enquiry = create(:enquiry)
        expect(enquiry.to_param).to eq enquiry.uid.parameterize
      end
    end

    describe "#flagged?" do
      it "returns flagged" do
        enquiry = create(:enquiry, flagged: true)
        expect(enquiry.flagged?).to eq true
      end
    end

    describe "#date" do
      it "returns created at datetime in user friendly format" do
        date = Time.now
        Timecop.freeze(date) do
          enquiry = create(:enquiry)
          expect(enquiry.date).to eq date.strftime("%I:%M %p %d/%m/%y")
        end
        Timecop.return
      end
    end

    describe "#origin" do
      it "should have a default source application of 'Service Manager'" do
        expect(enquiry.source_application).to eq('Service Manager')
      end

      it "should reveal the names of other source applications" do
        enquiry.origin = 1
        expect(enquiry.source_application).to eq('CMS')
        enquiry.origin = 2
        expect(enquiry.source_application).to eq('IBUS')
      end

      it "should not allow an invalid origin" do
        enquiry.origin = 9
        expect(enquiry).to be_invalid
      end
    end

    describe "#may_be_quoted?" do
      before do
        enquiry.customer_details_verified = true
      end

      it "cannot be quoted unless a manager has been assigned" do
        enquiry.manager = nil
        expect(enquiry.may_be_quoted?).to eq(false)
      end

      it "cannot be quoted unless an invoice company has been assigned" do
        enquiry.invoice_company = nil
        expect(enquiry.may_be_quoted?).to eq(false)
      end
      
      it "may be quoted if mandatory details are present and verification is done" do
        expect(enquiry.may_be_quoted?).to eq(true)
      end
    end

    describe "#quoted?" do
      before do
        enquiry.status = 'quoted'
      end

      it "knows when a quote has been created for this enquiry" do
        expect(enquiry.quoted?).to eq(true)
      end
    end

    describe "#process_notification" do
      before do
        enquiry.save
      end

      it "updates its status to 'pending quote' when a draft quote is created" do
        enquiry.process_notification( {event: :quote_created} )
        expect(enquiry.status).to eq('pending quote')
      end
    end

    describe "#hire_enquiry?" do
      before do
        common_params = { duration_unit: 'years', transmission_preference: 'Manual', number_of_vehicles: '1' }
        @hire_params_1 = common_params.merge( hire_start_date: '', ongoing_contract: '', units: '' )
        @hire_params_2 = common_params.merge( hire_start_date: '', ongoing_contract: '1', units: '' )
        @hire_params_3 = common_params.merge( hire_start_date: '', ongoing_contract: '', units: '1' )
        @hire_params_4 = common_params.merge( hire_start_date: '31/03/2016', ongoing_contract: '0', units: '1' )
        @hire_params_5 = common_params.merge( hire_start_date: '31/03/2016', ongoing_contract: '1', units: '0' )
        @hire_params_6 = common_params.merge( hire_start_date: '31/03/2016', ongoing_contract: '1', units: nil )
      end

      it "must identify invalid hire enquiries" do
        [@hire_params_1, @hire_params_2, @hire_params_3].each do |hire_params|
          enquiry.build_hire_enquiry(hire_params)
          expect(enquiry).to be_invalid
        end  
      end

      it "must identify valid hire enquiries" do
        [@hire_params_4, @hire_params_5, @hire_params_6].each do |hire_params|
          enquiry.build_hire_enquiry(hire_params)
          expect(enquiry).to be_valid
        end  
      end

    end

    describe "#new_customer_details_reported?" do
      before do
        customer_params = { first_name: 'Tinus', last_name: 'Visser', 
          email: 'tinus.visser@me.com', mobile: '0444111222', roles: [:customer],
          password: 'password', password_confirmation: 'password',
          client_attributes: {client_type: "person"}}
        customer = User.create(customer_params)
        company = create(:company, name: 'ABC Engineering')
        customer.representing_company = company
        customer.save
        enquiry.first_name = customer_params[:first_name]
        enquiry.last_name = customer_params[:last_name]
        enquiry.email = customer_params[:email]
        enquiry.phone = customer_params[:mobile]
        enquiry.user = customer
        enquiry.company = nil
      end

      it "knows when the enquiry from an existing user contains new contact details" do
        expect(enquiry.new_customer_details_reported?).to eq(false)
      end

      it "knows when the user reported a new first name" do
        enquiry.first_name = 'Tina'
        expect(enquiry.new_customer_details_reported?).to eq(true)
      end

      it "knows when the user reported a new last name" do
        enquiry.last_name = 'Tina'
        expect(enquiry.new_customer_details_reported?).to eq(true)
      end

      it "knows when the user reported a new phone number" do
        enquiry.phone = '0444333444'
        expect(enquiry.new_customer_details_reported?).to eq(true)
      end

      it "knows when the user reported the same company name" do
        enquiry.company = 'ABC Engineering'
        expect(enquiry.new_customer_details_reported?).to eq(false)
      end

      it "knows when the user reported a different company name" do
        enquiry.company = 'ABCDEF Engineering'
        expect(enquiry.new_customer_details_reported?).to eq(true)
      end
    end
  end

  describe "associations" do
    it { should belong_to(:enquiry_type) }
    it { should belong_to(:user) }
    it { should belong_to(:manager).class_name('User') }
    it { should belong_to(:invoice_company) }

    it { should have_one(:address).dependent(:destroy) }
    it { should accept_nested_attributes_for(:address).allow_destroy(true) }

    it { should have_many(:notes).dependent(:destroy) }
  end
end
