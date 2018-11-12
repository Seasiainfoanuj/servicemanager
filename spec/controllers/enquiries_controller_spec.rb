require "spec_helper"
require "rack/test"

describe EnquiriesController, type: :controller do
  let(:manager) { FactoryGirl.create(:user, :admin, email: 'troy@me.com') }
  let(:manager2) { FactoryGirl.create(:user, :admin, first_name: 'Sandra', last_name: 'Sanders', email: 'tris@me.com') }
  let(:company) { FactoryGirl.create(:company, name: 'Summerfield Engineering') }
  let(:customer) { FactoryGirl.create(:user, :customer, 
       first_name: 'Harry',
       last_name: 'Cilliers',
       email: 'harry.cilliers@example.com',
       representing_company: company) }
  let(:customer2) { FactoryGirl.create(:user, :customer, first_name: 'Gordon', last_name: 'Belfast', email: 'gordon@example.com')}

  let(:internal_company) { FactoryGirl.create(:invoice_company) }
  let!(:hire_enquiry) { FactoryGirl.create(:enquiry_type, name: 'Hire / Lease', slug: 'hire') }
  let!(:sales_enquiry) { FactoryGirl.create(:enquiry_type, name: 'Sales', slug: 'sales') }
  let!(:general_enquiry) { FactoryGirl.create(:enquiry_type, name: 'General', slug: 'general') }

  context "Visiting the show page of a General Enquiry" do
    let!(:enquiry) { FactoryGirl.create(:enquiry,
        enquiry_type: sales_enquiry,
        user: customer,
        first_name: 'Harry',
        last_name: 'Cilliers',
        email: 'harry.cilliers@example.com'
      )}

    describe "The manager sees the enquiry details" do
      before do
        signin(manager)
        get :show, id: enquiry.uid
      end

      it { should respond_with 200 }

      it "displays the enquiry show template" do
        expect(response).to render_template :show
      end
    end

    describe "The customer visits his own show page" do
      before do
        signin(customer)
        get :show, id: enquiry.uid
      end

      it { should respond_with 200 }

      it "displays the customer's own enquiry" do
        expect(response).to render_template :show
      end
    end

    describe "The customer attempts to visit another customer's show page" do
      before do
        signin(customer2)
        get :show, id: enquiry.uid
      end

      it { should respond_with 302 }

      it "redirects the user to the home page" do
        expect(response).to redirect_to(root_url)
      end
    end
  end  

  context "Visiting the new enquiry page" do
    describe "A manager visits the new enquiry page" do
      before do
        signin(manager)
        get :new
      end

      it { should respond_with 200 }

      it "displays the enquiry new template" do
        expect(response).to render_template :new
      end
    end

    describe "A signed-in customer visits the new enquiry page" do
      before do
        signin(customer)
        get :new
      end

      it { should respond_with 200 }

      it "displays the enquiry new template" do
        expect(response).to render_template :new
      end
    end

    describe "A non-signed-in customer visits the new enquiry page" do
      before do
        get :new
      end

      it { should respond_with 200 }

      it "displays the enquiry new template" do
        expect(response).to render_template :new
      end
    end
  end

  context "Creating a new enquiry" do
    describe "A manager creates a general enquiry" do
      before do
        enquiry_params = { 
          enquiry_type_id: sales_enquiry.id,
          first_name: 'Harry',
          last_name: 'Cilliers',
          email: 'harry.cilliers@example.com',
          phone: '0537543543',
          details: 'This is my enquiry'
        }
        signin(manager)
        put :create, enquiry: enquiry_params
      end

      it "creates a new sales enquiry" do
        enquiry = Enquiry.last
        expect(flash[:success]).to eq("Enquiry #{enquiry.uid} was successfully created.")
        expect(response).to redirect_to(enquiries_path)
      end
    end

    describe "A manager creates a hire enquiry" do
      before do
        enquiry_params = { 
          enquiry_type_id: hire_enquiry.id,
          first_name: 'Harry',
          last_name: 'Cilliers',
          email: 'harry.cilliers@example.com',
          phone: '0537543543',
          details: 'This is my enquiry',
          hire_enquiry_attributes: {
            hire_start_date_field: (Date.today + 7.days).strftime("%d/%m/%Y"),
            units: 4, 
            duration_unit: 'weeks',  
            number_of_vehicles: 1, 
            minimum_seats: 28, 
            delivery_required: "1",
            delivery_location: "Downtown", 
            transmission_preference: "Automatic" }
        }
        signin(manager)
        put :create, enquiry: enquiry_params
      end

      it "creates a new enquiry" do
        enquiry = Enquiry.last
        expect(flash[:success]).to eq("Enquiry #{enquiry.uid} was successfully created.")
        expect(response).to redirect_to(enquiries_path)
      end
    end

    describe "A customer, already belonging to some company creates a corporate enquiry" do
      before do
        enquiry_params = { 
          enquiry_type_id: sales_enquiry.id,
          first_name: 'Harry',
          last_name: 'Cilliers',
          email: 'harry.cilliers@example.com',
          phone: '0537543543',
          details: 'This is my enquiry',
          company: 'Round bearings Pty Ltd',
          address_attributes: {
            line_1: '13 Sunshine Avenue', 
            line_2: '',
            suburb: 'Sunnybank',
            state: 'QLD', 
            postcode: '5082',
            country: 'Australia' }
          }
        signin(customer)
        put :create, enquiry: enquiry_params
      end  

      it "creates a new enquiry" do
        enquiry = Enquiry.last
        expect(response).to redirect_to(enquiry_submitted_path(reference: enquiry.uid))
        expect(enquiry.user.representing_company).to eq(company)
      end
    end

    describe "A customer, not belonging to any company creates a corporate enquiry" do
      before do
        enquiry_params = { 
          enquiry_type_id: sales_enquiry.id,
          first_name: 'Gordon',
          last_name: 'Belfast',
          email: 'gordon@example.com',
          phone: '0531212343',
          details: 'This is from Gordon',
          company: 'Round bearings Pty Ltd',
          address_attributes: {
            line_1: '23 Sunshine Avenue', 
            line_2: '',
            suburb: 'Sunnybank',
            state: 'QLD', 
            postcode: '5082',
            country: 'Australia' }
          }
        signin(customer)
        put :create, enquiry: enquiry_params
      end  

      it "creates a new enquiry" do
        enquiry = Enquiry.last
        expect(response).to redirect_to(enquiry_submitted_path(reference: enquiry.uid))
        expect(enquiry.user.representing_company.name).to eq('Round bearings Pty Ltd')
      end
    end

    describe "A customer creates a hire enquiry was insufficient parameters" do
      before do
        enquiry_params = { 
          enquiry_type_id: hire_enquiry.id,
          first_name: 'Harry',
          last_name: 'Yardley',
          email: 'harry.yardley@example.com',
          phone: '0537543543',
          details: 'This is my enquiry',
          hire_enquiry_attributes: {
            hire_start_date_field: (Date.today + 7.days).strftime("%d/%m/%Y"),
            units: 4, 
            duration_unit: 'weeks',  
            number_of_vehicles: 1, 
            minimum_seats: 28, 
            delivery_required: "1",
            delivery_location: "", 
            transmission_preference: "Automatic" 
          }
        }
        signin(customer)
        put :create, { hire_enquiry_check: 'on', enquiry: enquiry_params }
      end

      it "fails to create an enquiry", :js => true do
        expect(response).to render_template :new
      end
    end
  end

  context "Updating an enquiry" do
    describe "A manager updates a general enquiry" do
      before do
        @old_enquiry = Enquiry.create(
          enquiry_type_id: sales_enquiry.id,
          first_name: 'Harry',
          last_name: 'Cilliers',
          email: 'harry.cilliers@example.com',
          phone: '0537543543',
          details: 'This is my enquiry'
          )
        enquiry_params = { 
          enquiry_type_id: general_enquiry.id,
          first_name: 'Harvey',
          last_name: 'Clavier',
          email: 'harry.cilliers@example.com',
          phone: '0537543444',
          details: 'This is another enquiry'
        }

        signin(manager)
        put :update, id: @old_enquiry.uid, enquiry: enquiry_params
      end

      it "updates the enquiry" do
        expect(flash[:success]).to eq("Enquiry #{@old_enquiry.uid} was successfully updated.")
        expect(response).to redirect_to("/enquiries/#{@old_enquiry.uid}?referer=update")
        @old_enquiry.reload
        expect(@old_enquiry.last_name).to eq('Clavier')
        expect(@old_enquiry.phone).to eq('0537543444')
        expect(@old_enquiry.details).to eq('This is another enquiry')
      end
    end
  end

  context "Updating an enquiry and reassign to different manager at the same time" do
    describe "A manager updates a general enquiry" do
      before do
        @old_enquiry = Enquiry.create(
          enquiry_type_id: sales_enquiry.id,
          first_name: 'Harry',
          last_name: 'Cilliers',
          email: 'harry.cilliers@example.com',
          phone: '0537543543',
          details: 'This is my enquiry',
          manager_id: manager.id
          )
        enquiry_params = { 
          enquiry_type_id: general_enquiry.id,
          first_name: 'Harvey',
          last_name: 'Clavier',
          email: 'harry.cilliers@example.com',
          phone: '0537543444',
          details: 'This is another enquiry',
          manager_id: manager2.id
        }

        signin(manager)
        PublicActivity.with_tracking do
          put :update, id: @old_enquiry.uid, enquiry: enquiry_params
        end
      end

      it "updates the enquiry and reassigns it to new manager" do
        expect(flash[:success]).to eq("Enquiry #{@old_enquiry.uid} was successfully updated.")
        expect(response).to redirect_to("/enquiries/#{@old_enquiry.uid}?referer=update")
        @old_enquiry.reload
        expect(@old_enquiry.last_name).to eq('Clavier')
        expect(@old_enquiry.phone).to eq('0537543444')
        expect(@old_enquiry.manager.last_name).to eq('Sanders')
      end

      it "generates a reassigned activity authored by logged in manager" do
        expect(@old_enquiry.activities.last.key).to eq('enquiry.reassigned')
        expect(@old_enquiry.activities.last.owner).to eq(manager)
        expect(@old_enquiry.activities.last.recipient).to eq(manager2)
      end
    end

    describe "A manager updates an unmanaged enquiry" do
      before do
        @old_enquiry = Enquiry.create(
          enquiry_type_id: sales_enquiry.id,
          first_name: 'Harry',
          last_name: 'Cilliers',
          email: 'harry.cilliers@example.com',
          phone: '0537543543',
          details: 'This is my enquiry'
          )
        enquiry_params = { 
          enquiry_type_id: general_enquiry.id,
          first_name: 'Harvey',
          last_name: 'Clavier',
          email: 'harry.cilliers@example.com',
          phone: '0537543444',
          details: 'This is another enquiry',
          manager_id: manager2.id
        }

        signin(manager)
        PublicActivity.with_tracking do
          put :update, id: @old_enquiry.uid, enquiry: enquiry_params
        end
      end

      it "updates the enquiry and assigns it to a manager" do
        expect(flash[:success]).to eq("Enquiry #{@old_enquiry.uid} was successfully updated.")
        expect(response).to redirect_to("/enquiries/#{@old_enquiry.uid}?referer=update")
        @old_enquiry.reload
        expect(@old_enquiry.last_name).to eq('Clavier')
        expect(@old_enquiry.phone).to eq('0537543444')
        expect(@old_enquiry.manager.last_name).to eq('Sanders')
      end

      it "generates an assigned activity authored by logged in manager" do
        expect(@old_enquiry.activities.last.key).to eq('enquiry.assigned')
        expect(@old_enquiry.activities.last.owner).to eq(manager)
        expect(@old_enquiry.activities.last.recipient).to eq(manager2)
      end
    end

    describe "A manager updates a hire enquiry" do
      before do
        @old_enquiry = Enquiry.new( 
          enquiry_type_id: hire_enquiry.id,
          first_name: 'Harry',
          last_name: 'Cilliers',
          email: 'harry.cilliers@example.com',
          phone: '0537543543',
          details: 'This is my enquiry')
        @old_enquiry.hire_enquiry_attributes = {
            hire_start_date_field: (Date.today + 7.days).strftime("%d/%m/%Y"),
            units: 4, 
            duration_unit: 'weeks',  
            number_of_vehicles: 1, 
            minimum_seats: 28, 
            delivery_required: "1",
            delivery_location: "Downtown", 
            transmission_preference: "Automatic" }
        @old_enquiry.save!
        enquiry_params = { phone: '0537511511', hire_enquiry_attributes: {
            hire_start_date_field: (Date.today + 10.days).strftime("%d/%m/%Y"),
            units: 40, 
            duration_unit: 'days',  
            number_of_vehicles: 2, 
            minimum_seats: 30, 
            delivery_required: "0",
            delivery_location: "", 
            ongoing_contract: true,
            transmission_preference: "Manual",
            special_requirements: 'My special requirements' }
          }
        signin(manager)
        put :update, id: @old_enquiry.uid, enquiry: enquiry_params
      end

      it "has been created" do
        expect(flash[:success]).to eq("Enquiry #{@old_enquiry.uid} was successfully updated.")
        expect(response).to redirect_to("/enquiries/#{@old_enquiry.uid}?referer=update")
        @old_enquiry.reload
        expect(@old_enquiry.phone).to eq('0537511511')
      end
    end      

  end

  context "Assigning enquiry to a manager and internal company" do
    before do
      enquiry_params = { manager_id: manager.id, invoice_company_id: internal_company.id, seen: 0 }
      @enquiry = create(:enquiry, enquiry_type_id: sales_enquiry.id, 
        email: 'harry.cilliers@example.com', user: customer, manager: nil)
      signin(manager)

      PublicActivity.with_tracking do
        put :assign, id: @enquiry.uid, enquiry: enquiry_params
      end
    end

    it "assigns an enquiry manager" do
      allow(EnquiryMailer).to receive(:delay).and_return(nil)
      expect(flash[:success]).to eq("Enquiry ##{@enquiry.uid} assigned to #{manager.name}")
      expect(Enquiry.last.invoice_company).to eq(internal_company)
    end

    it "generates an assigned activity authored by logged in manager" do
      expect(@enquiry.activities.last.key).to eq('enquiry.assigned')
      expect(@enquiry.activities.last.owner).to eq(manager)
      expect(@enquiry.activities.last.recipient).to eq(manager)
    end
  end  

  context "Reassigning enquiry to a manager and internal company" do
    before do
      enquiry_params = { manager_id: manager2.id, invoice_company_id: internal_company.id, seen: 0 }
      @enquiry = create(:enquiry, enquiry_type_id: sales_enquiry.id, 
        email: 'harry.cilliers@example.com', user: customer, manager: manager)
      signin(manager)
      PublicActivity.with_tracking do
        put :assign, id: @enquiry.uid, enquiry: enquiry_params
      end
    end

    it "reassigns an enquiry manager" do
      allow(EnquiryMailer).to receive(:delay).and_return(nil)
      expect(flash[:success]).to eq("Enquiry ##{@enquiry.uid} reassigned to #{manager2.name}")
      expect(Enquiry.last.invoice_company).to eq(internal_company)
    end

    it "generates a reassigned activity authored by logged in manager" do
      expect(@enquiry.activities.last.key).to eq('enquiry.reassigned')
      expect(@enquiry.activities.last.owner).to eq(manager)
      expect(@enquiry.activities.last.recipient).to eq(manager2)
    end
  end
end
