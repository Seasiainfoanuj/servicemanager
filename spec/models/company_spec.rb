require "spec_helper"
describe Company do
  describe "validations" do

    let(:user) { User.first || create(:user) }

    before do
      @company = Company.first || build(:company)
    end

    subject { @company }

    it "has a valid factory" do
      expect(@company).to be_valid
    end

    it { should respond_to(:name) }
    it { should respond_to(:website) }
    it { should respond_to(:abn) }
    it { should respond_to(:vendor_number) }
    it { should respond_to(:archived_at) }
    it { should accept_nested_attributes_for(:addresses) }


    describe "#name" do
      it "should be present" do
        @company.name = ""
        expect(@company).to be_invalid
      end

      it "should be between 2 and 70 characters long" do
        ['a', 'a'*71].each do |name|
          @company.name = name
          expect(@company).to be_invalid
        end
      end

      it "should be unique" do
        @company.save!
        company_2 = @company.dup
        expect(company_2).to be_invalid
      end
    end

    describe "#Company.create_from_name" do
      before do
        @old_company = create(:company, name: 'Registered Name', trading_name: 'Trading Name')
      end

      it "should return existing company if Registered Name is provided" do
        expect(Company.create_from_name('Registered Name')).to eq(@old_company)
      end

      it "should return existing company if Trading Name is provided" do
        expect(Company.create_from_name('Trading Name')).to eq(@old_company)
      end

      it "should create a new company if the name is not found" do
        new_company = Company.create_from_name('Brand New Name')
        expect(new_company.name).to eq('Brand New Name')
        expect(new_company.trading_name).to eq('Brand New Name')
      end
    end

    describe "#trading_name" do
      it "should be optional" do
        @company.trading_name = ""
        expect(@company).to be_valid
      end

      it "should be between 2 and 50 characters long" do
        ['a', 'a'*51].each do |name|
          @company.trading_name = name
          expect(@company).to be_invalid
        end
      end
    end

    describe "#abn" do
      it "should be optional" do
        @company.abn = ""
        expect(@company).to be_valid
      end

      it "should contain 11 digits" do
        @company.abn = "1204 2168 743"
        expect(@company).to be_valid
        invalid_abns = ["1234567890", "A1234567890", "123456789012"]
        invalid_abns.each do |try_abn|
          @company.abn = try_abn
          expect(@company).to be_invalid
        end
      end

      it "should pass the weighting test" do
        @company.abn = "11637968737"
        expect(@company).to be_valid
        @company.abn = "12045568744"
        expect(@company).to be_invalid
      end
    end

    describe "#can_be_deleted" do
      it "should confirm that a company without contacts may be deleted" do
        expect(@company.can_be_deleted?).to be(true)
      end

      it "should indicate that a company with contacts cannot be deleted" do
        @company.save!
        create(:user, representing_company: @company)
        expect(@company.can_be_deleted?).to be(false)
      end
    end

    describe "#postal_address" do
      it "should return nil if it has no postal address" do
        expect(@company.postal_address).to eq(nil)
      end

      it "should return the postal address when present" do
        @company.addresses = [build(:address, address_type: Address::POSTAL, user: user, line_1: '123 Long Street')]
        @company.save!
        expect(@company.postal_address.line_1).to eq('123 Long Street')
      end
    end

    describe "#physical_address" do
      it "should return nil if it has no physical address" do
        expect(@company.physical_address).to eq(nil)
      end

      it "should return the physical address when present" do
        @company.addresses = [build(:address, address_type: Address::PHYSICAL, user: user, line_1: '123 Long Street')]
        @company.save!
        expect(@company.physical_address.line_1).to eq('123 Long Street')
      end
    end

    describe "#billing_address" do
      it "should return nil if it has no billing address" do
        expect(@company.billing_address).to eq(nil)
      end

      it "should return the billing address when present" do
        @company.addresses = [build(:address, address_type: Address::BILLING, user: user, line_1: '123 Long Street')]
        @company.save!
        expect(@company.billing_address.line_1).to eq('123 Long Street')
      end
    end

    describe "#preferred_addresses" do
      let(:company) { Company.first || create(:company) }

      before do
        physical_address = build(:address, address_type: Address::PHYSICAL)
        postal_address = build(:address, address_type: Address::POSTAL)
        delivery_address = build(:address, address_type: Address::DELIVERY)
        company.addresses.build(physical_address.attributes)
        company.addresses.build(postal_address.attributes)
        company.addresses.build(delivery_address.attributes)
        company.save!
        company.reload
        @physical_address = Address.physical.first
        @postal_address = Address.postal.first
      end

      it "provides a company's preferred address for vehicle contracts as the physical address" do
        expect(company.preferred_address({usage: :vehicle_contract})).to eq(@physical_address)
      end

      it "provides a company's postal address as an alternative preferred address" do
        @physical_address.destroy
        expect(company.preferred_address({usage: :vehicle_contract})).to eq(@postal_address)
      end

      it "provides no alternative address if the customer has neither a physical nor a postal address" do
        @physical_address.destroy
        @postal_address.destroy
        expect(company.preferred_address({usage: :vehicle_contract})).to eq(nil)
      end
    end

    describe "#short_name" do
      before do
        @name1 = "Fritz and Sons"
        @name2 = "#{'A' * 30}B" 
      end

      it "returns a shorter name unchanged" do
        @company.name = @name1
        expect(@company.short_name).to eq(@name1)
      end

      it "truncates a long name" do
        @company.name = @name2
        expected_name = "#{'A' * 30}" + "..."
        expect(@company.short_name).to eq(expected_name)
      end
    end

    # describe "#authorised_users" do
    #   before do
    #     @company.save
    #     @contact1 = create(:user, :contact, email: 'susan@me.com', receive_emails: false, 
    #                        representing_company: @company, client_attributes: { client_type: 'person'})
    #     @contact2 = create(:user, :contact, email: 'sonja@me.com', receive_emails: false, 
    #                        representing_company: @company, client_attributes: { client_type: 'person'})
    #   end

    #   it "regards all contacts as authorised when company has no authorised contacts" do
    #     expect(@company.authorised_users.count).to eq(2)
    #   end 

    #   it "selects only authorised users when company has at least one authorised user" do
    #     @contact2.update(receive_emails: true)
    #     expect(@company.authorised_users.count).to eq(1)
    #   end
    # end

  end

  describe "associations" do
    it { should belong_to(:default_contact).class_name("User") }
    it { should have_many(:contacts) }
    it { should have_many(:addresses) }
  end

end