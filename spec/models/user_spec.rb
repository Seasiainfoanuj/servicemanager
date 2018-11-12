require "spec_helper"

describe User do
  describe "validations" do
    let(:user) { User.first || build(:user) }

    it "has a valid factory" do
      expect(user).to be_valid
    end

    it { should validate_presence_of :email }
    it { should validate_uniqueness_of :email }
    it { should respond_to :archived_at }
    it { should respond_to :xero_identifier }
    it { should respond_to :abn }

    it "should a valid resource name" do
      expect(user.resource_name).to eq("User: #{user.name}")
    end

    describe "#first_name" do
      it "must have a valid length" do
        ['a', 'a'*41].each do |name|
          user.first_name = name
          expect(user).to be_invalid
        end
      end
    end

    describe "#last_name" do
      it "must have a valid length" do
        ['a', 'a'*41].each do |name|
          user.last_name = name
          expect(user).to be_invalid
        end
      end
    end

    describe "#phone" do
      it "must have a valid length" do
        ['1'*7, '1'*21].each do |phone|
          user.phone = phone
          expect(user).to be_invalid
        end
      end

      it "must be optional" do
        user.phone = nil
        expect(user).to be_valid
      end
    end

    describe "#fax" do
      it "must have a valid length" do
        ['1'*7, '1'*21].each do |fax|
          user.fax = fax
          expect(user).to be_invalid
        end
      end

      it "must be optional" do
        user.fax = nil
        expect(user).to be_valid
      end
    end

    describe "#mobile" do
      it "must have a valid length" do
        ['1'*9, '1'*21].each do |mobile|
          user.mobile = mobile
          expect(user).to be_invalid
        end
      end

      it "must be optional" do
        user.mobile = nil
        expect(user).to be_valid
      end
    end

    describe "#email" do
      it "must have a valid length" do
        ['a'*7, 'a'*51].each do |email|
          user.email = email
          expect(user).to be_invalid
        end
      end
    end

    describe "#name" do
      context "when first_name and last_name are present" do
        it "should return first_name and last_name" do
          user = build(:user, first_name: "John", last_name: "Doe")
          expect(user.name).to eq "John Doe"
        end
      end
      context "when first_name and last_name are not present" do
        it "should return email" do
          user = build(:user, first_name: "", last_name: "", email: "john@example.com")
          expect(user.name).to eq "john@example.com"
        end
      end

      context "when first_name and last_name not present present" do
        it "should return first name" do
          user = build(:user, first_name: "John", last_name: "", email: "john@example.com")
          expect(user.name).to eq "John"
        end
      end

      context "when first_name not present and last_name present" do
        it "should return first name" do
          user = build(:user, first_name: "", last_name: "Doe", email: "john@example.com")
          expect(user.name).to eq "Doe"
        end
      end
    end

    describe "#ref_name" do
      context "if first_name and last_name are present" do
        it "should return (first_name last_name) email as string" do
          user = build(:user)
          expect(user.ref_name).to eq "#{user.first_name} #{user.last_name} (#{user.email})"
        end
      end
      context "if first_name and last_name are NOT present" do
        it "should return email as string" do
          user_1 = build(:user, first_name: nil, last_name: nil)
          user_2 = build(:user, first_name: "", last_name: "")
          expect(user_1.ref_name).to eq user_1.email
          expect(user_2.ref_name).to eq user_2.email
        end
      end
    end

    describe "#company_name" do
      context "when company is present" do
        it "returns company, name and email with - seperators" do
          company = create(:company, name: 'Turbo Gears Pty Ltd')
          user = build(:user, representing_company: company, first_name: "John", last_name: "Doe", email: "john@example.com")
          expect(user.company_name).to eq "Turbo Gears Pty Ltd - John Doe - john@example.com"
        end
      end

      context "when company is not present but name is" do
        it "returns company, name and email with - seperators" do
          user = build(:user, first_name: "John", last_name: "Doe", email: "john@example.com")
          expect(user.company_name).to eq "John Doe - john@example.com"
        end
      end

      context "when company is present and name matches email" do
        it "returns company and email with - seperators" do
          company = create(:company, name: 'Turbo Gears Pty Ltd')
          user = build(:user, representing_company: company, first_name: nil, last_name: nil, email: "john@example.com")
          expect(user.company_name).to eq "Turbo Gears Pty Ltd - john@example.com"
        end
      end

      context "when company is not present and name matches email" do
        it "returns email only with no - seperators" do
          user = build(:user, first_name: nil, last_name: nil, email: "john@example.com")
          expect(user.company_name).to eq "john@example.com"
        end
      end
    end

    describe "#employee?" do
      it "regards a user with admin rights as an employee" do
        user.roles = [:supplier]
        expect(user.employee?).to eq(false)
        user.roles << [:admin]
        expect(user.employee?).to eq(true)
      end
    end

    describe "#company_name_short" do
      context "when company exists" do
        it "returns company" do
          company = create(:company)
          user = build(:user, representing_company: company, first_name: "John", last_name: "Doe", email: "john@example.com")
          expect(user.company_name_short).to eq "Ficticious Sales"
        end
      end

      context "when company does not exists" do
        it "defaults to name" do
          user = build(:user, first_name: "John", last_name: "Doe")
          expect(user.company_name_short).to eq "John Doe"
        end
      end
    end

    describe "#contact_details" do
      it "formats the person name from the available name parts" do
        user1 = build(:user, first_name: "John", last_name: "Doe")
        user2 = build(:user, first_name: "John", last_name: "")
        user3 = build(:user, first_name: "", last_name: "Doe")
        expect(user1.person_names).to eq("John Doe")
        expect(user2.person_names).to eq("John")
        expect(user3.person_names).to eq("Doe")
      end

      it "formats the phone numbers from the available parts" do
        user = build(:user, phone: '1234567', fax: '7654321', mobile: '012444555')
        expect(user.phone_numbers).to eq('Phone: 1234567, Fax: 7654321, Mobile: 012444555')
        user = build(:user, phone: '1234567', fax: '', mobile: '012444555')
        expect(user.phone_numbers).to eq('Phone: 1234567, Mobile: 012444555')
        user = build(:user, phone: '', fax: '', mobile: '012444555')
        expect(user.phone_numbers).to eq('Mobile: 012444555')
      end

      it "formats a contact details hash from the available parts" do
        user = build(:user, first_name: "John", last_name: "Doe", email: 'jdoe@google.com', phone: '1234567', fax: '7654321', mobile: '012444555')
        expect(user.contact_details[:name]).to eq("John Doe")
        expect(user.contact_details[:email]).to eq("jdoe@google.com")
        expect(user.contact_details[:phones]).to eq('Phone: 1234567, Fax: 7654321, Mobile: 012444555')
        user = build(:user, first_name: "John", last_name: "", email: '', phone: '1234567', fax: '', mobile: '')
        expect(user.contact_details[:name]).to eq("John")
        expect(user.contact_details[:email]).to eq("")
        expect(user.contact_details[:phones]).to eq('Phone: 1234567')
      end
    end

    describe "#dob_field" do
      it "returns dob_field in user friendly format" do
        user = create(:user, dob: Date.today)
        expect(user.dob_field).to eq Date.today.strftime("%d/%m/%Y")
      end

      it "parses dob_field in db friendly format" do
        date = Date.today.strftime("%d/%m/%Y")
        user = create(:user, dob_field: date)
        expect(user).to be_valid
        expect(user.dob_field).to eq date
      end
    end

    describe "#ensure_authentication_token" do
      it "generates authentication token if nil" do
        user = create(:user, authentication_token: nil)
        user.save
        expect(user.authentication_token).to_not eq nil
      end
    end

    describe "#representing_company" do
      it "should reference the company it represents" do
        company = Company.first || FactoryGirl.create(:company)
        user = User.first || FactoryGirl.build(:user)
        user.representing_company = company
        expect(user.representing_company).to eq(company)
      end
    end

    context "avatar" do
      it { should have_attached_file(:avatar) }
      it { should validate_attachment_content_type(:avatar).
                  allowing('image/jpeg', 'image/png').
                  rejecting('text/plain', 'text/xml') }
      it { should validate_attachment_size(:avatar).
                    less_than(5.megabytes) }
    end
    
    describe "#abn" do
      it "should be optional" do
        user.abn = ""
        expect(user).to be_valid
      end
      it "should contain 11 digits" do
        user.abn = "1204 2168 743"
        expect(user).to be_valid
        invalid_abns = ["1234567890", "A1234567890", "123456789012"]
        invalid_abns.each do |try_abn|
          user.abn = try_abn
          expect(user).to be_invalid
        end
      end
      it "should pass the weighting test" do
        user.abn = "11637968737"
        expect(user).to be_valid
        user.abn = "12045568744"
        expect(user).to be_invalid
      end
    end

    describe "#valid_roles?" do
      before do
        @valid_roles = [[:contact], [:admin], [:customer],[:employee], [:quote_customer], [:customer, :supplier]]
        @invalid_roles = [[:contact, :supplier], [:admin, :service_provider], [:customer, :quote_customer]]
      end
      
      it "accepts valid roles" do
        @valid_roles.each do |roles|
          user.roles = roles
          expect(user).to be_valid
        end
      end  

      it "rejects invalid roles" do
        @invalid_roles.each do |roles|
          user.roles = roles
          expect(user).to be_invalid
        end
      end  
    end

    describe "#update_roles" do
      it "does not change a customer role when an enquiry is created" do
        user.roles = [:customer]
        user.save
        user.update_roles( { event: :enquiry_created} )
        expect(user.roles.count).to eq(1)
        expect(user.roles.first).to eq(:customer)
      end 

      it "changes a contact role to quote_customer when a quote is created" do
        user.roles = [:contact]
        user.save
        user.update_roles( { event: :quote_created} )
        expect(user.roles.count).to eq(1)
        expect(user.roles.first).to eq(:quote_customer)
      end 

      it "does not change a quote_customer role when a quote is created" do
        user.roles = [:quote_customer]
        user.save
        user.update_roles( { event: :quote_created} )
        expect(user.roles.count).to eq(1)
        expect(user.roles.first).to eq(:quote_customer)
      end

      it "add a quote_customer role to supplier role when a quote is created" do
        user.roles = [:supplier]
        user.save
        user.update_roles( { event: :quote_created} )
        expect(user.roles.count).to eq(2)
        expect(user.roles.include?(:supplier)).to eq(true)
        expect(user.roles.include?(:quote_customer)).to eq(true)
      end
    end
  end

  context "#assign_hire_quote_role_from" do
    let!(:user) { create(:user) }

    describe "when origin contact had contact role" do
      before do
        @original_contact = create(:user, :contact, first_name: "Petrov", last_name: "Karpov", email: "petrov@example.com")
        @expected_role_changes = [[:contact, :contact], [:customer, :customer]]
      end

      it "should not change the new contact's role if original contact had contact role" do
        @expected_role_changes.each do |roles|
          user.update(roles: [roles[0]])
          user.assign_hire_quote_role_from(@original_contact)
          expect(user.reload.roles.first).to eq(roles[1])
        end
      end
    end

    describe "when origin contact had quote_customer role" do
      before do
        @original_contact = create(:user, :quote_customer, first_name: "Petricia", last_name: "Karpov", email: "petricia@example.com")
        @expected_role_changes = [[:contact, :quote_customer], [:quote_customer, :quote_customer], [:customer, :customer]]
      end

      it "should change the new contact's role to include the minimum quoting roles of the original contact" do
        @expected_role_changes.each do |roles|
          user.update(roles: [roles[0]])
          user.assign_hire_quote_role_from(@original_contact)
          expect(user.reload.roles.first).to eq(roles[1])
        end
      end

      it "should add the role of quote_customer if the new contact is a supplier or service_provider" do
        user.update(roles: [:supplier])
        user.assign_hire_quote_role_from(@original_contact)
        user.reload
        expect(user.roles.count).to eq(2)
        expect(user.roles.include?(:quote_customer)).to eq(true)
      end
    end

    describe "when origin contact had customer role" do
      before do
        @original_contact = create(:user, :customer, first_name: "Petricia", last_name: "Karpov", email: "petricia@example.com")
        @expected_role_changes = [[:contact, :customer], [:quote_customer, :customer], [:customer, :customer]]
      end

      it "should change the new contact's role to include the minimum quoting roles of the original contact" do
        @expected_role_changes.each do |roles|
          user.update(roles: [roles[0]])
          user.assign_hire_quote_role_from(@original_contact)
          expect(user.reload.roles.first).to eq(roles[1])
        end
      end

      it "should add the role of customer if the new contact is a supplier or service_provider" do
        user.update(roles: [:service_provider])
        user.assign_hire_quote_role_from(@original_contact)
        user.reload
        expect(user.roles.count).to eq(2)
        expect(user.roles.include?(:customer)).to eq(true)
      end
    end
  end

  describe "#addresses" do
    let(:user) { User.customer.first || create(:user, :customer) }

    before do
      physical_address = build(:address, address_type: Address::PHYSICAL)
      postal_address = build(:address, address_type: Address::POSTAL)
      delivery_address = build(:address, address_type: Address::DELIVERY)
      user.addresses.build(physical_address.attributes)
      user.addresses.build(postal_address.attributes)
      user.addresses.build(delivery_address.attributes)
      user.save!
      user.reload
      @physical_address = Address.physical.first
      @postal_address = Address.postal.first
    end

    it "provides a customer's preferred address for vehicle contracts as the physical address" do
      expect(user.preferred_address({usage: :vehicle_contract, role: :customer})).to eq(@physical_address)
    end

    it "provides a customer's postal address as an alternative preferred address" do
      @physical_address.destroy
      expect(user.preferred_address({usage: :vehicle_contract, role: :customer})).to eq(@postal_address)
    end

    it "provides no alternative address if the customer has neither a physical nor a postal address" do
      @physical_address.destroy
      @postal_address.destroy
      expect(user.preferred_address({usage: :vehicle_contract, role: :customer})).to eq(nil)
    end
  end

  describe "scopes & filters" do
    before(:each) do
      2.times { create(:user, :admin) }
      3.times { create(:user, :supplier) }
      4.times { create(:user, :service_provider) }
      5.times { create(:user, :customer) }
      6.times { create(:user, :quote_customer) }
      7.times { create(:user, :employee) }
    end

    it "return users with_role" do
      expect(User.with_role(:admin).count).to eq 2
      expect(User.with_role(:supplier).count).to eq 3
      expect(User.with_role(:service_provider).count).to eq 4
      expect(User.with_role(:customer).count).to eq 5
      expect(User.with_role(:quote_customer).count).to eq 6
      expect(User.with_role(:employee).count).to eq 7
    end

    it "return users with_roles" do
      expect(User.with_roles(:admin, :supplier).count).to eq 5
    end

    it "return admins" do
      expect(User.filter_by_admin.count).to eq 2
    end

    it "return suppliers" do
      expect(User.filter_by_supplier.count).to eq 3
    end

    it "return service_providers" do
      expect(User.filter_by_service_provider.count).to eq 4
    end

    it "return service_providers, as well as admins" do
      expect(User.filter_by_service_provider( {include_admin: true} ).count).to eq 6
    end

    it "return customers" do
      expect(User.filter_by_customer.count).to eq 5
    end

    it "return quote_customers which includes customers" do
      expect(User.filter_by_quote_customer.count).to eq 11
    end
  end

  describe "associations" do
    it { should have_many(:stock_requests).class_name('StockRequest').with_foreign_key('supplier_id') }
    it { should have_many(:supplied_stocks).class_name('Stock').with_foreign_key('supplier_id') }
    it { should have_many(:supplied_vehicles).class_name('Vehicle').with_foreign_key('supplier_id') }
    it { should have_many(:vehicles).with_foreign_key('owner_id') }
    it { should have_many(:vehicle_log_entries).class_name('VehicleLog').with_foreign_key('service_provider_id') }

    it { should have_many(:workorders).with_foreign_key('service_provider_id') }
    it { should have_many(:customer_workorders).class_name('Workorder').with_foreign_key('customer_id') }
    it { should have_many(:managed_workorders).class_name('Workorder').with_foreign_key('manager_id') }

    it { should have_many(:hire_agreements).with_foreign_key('customer_id') }
    it { should have_many(:managed_hire_agreements).class_name('HireAgreement').with_foreign_key('manager_id') }
    it { should have_many(:off_hire_jobs).with_foreign_key('manager_id') }

    it { should have_many(:quotes).with_foreign_key('customer_id') }
    it { should have_many(:managed_quotes).class_name('Quote').with_foreign_key('manager_id') }
    it { should have_many(:vehicle_contracts).with_foreign_key('customer_id') }

    it { should have_many(:sent_messages).class_name('Message').with_foreign_key('sender_id') }
    it { should have_many(:received_messages).class_name('Message').with_foreign_key('recipient_id') }

    it { should have_many(:managed_builds).class_name('Build').with_foreign_key('manager_id') }
    it { should have_many(:build_orders).with_foreign_key('service_provider_id') }
    it { should have_many(:managed_build_orders).class_name('BuildOrder').with_foreign_key('manager_id') }

    it { should have_many(:po_requests).with_foreign_key('service_provider_id') }

    it { should have_many(:job_subscribers) }

    it { should have_many(:notes).dependent(:destroy) }

    it { should have_many(:subscribed_workorders).
         conditions("job_subscribers.job_type = 'Workorder'").
         through(:job_subscribers).source(:workorder) }

    it { should have_many(:subscribed_build_orders).
         conditions("job_subscribers.job_type = 'BuildOrder'").
         through(:job_subscribers).source(:build_order) }

    it { should have_many(:subscribed_off_hire_jobs).
         conditions("job_subscribers.job_type = 'OffHireJobs'").
         through(:job_subscribers).source(:off_hire_job) }

    it { should have_many(:addresses).dependent(:destroy) }
    it { should accept_nested_attributes_for(:addresses).allow_destroy(true) }

    it { should have_one(:licence).dependent(:destroy) }
    it { should accept_nested_attributes_for(:licence).allow_destroy(true) }

    it { should have_many(:orders).class_name('SalesOrder').with_foreign_key('customer_id') }
    it { should have_many(:managed_orders).class_name('SalesOrder').with_foreign_key('manager_id') }

    it { should have_one(:client) }
    it { should accept_nested_attributes_for(:client) }

    it { should belong_to(:employer).class_name('InvoiceCompany') }

  end
end
