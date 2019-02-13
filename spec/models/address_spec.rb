require 'spec_helper'

describe Address do
  describe "validations" do

    before do
      @user = create(:user)
      @user.addresses.build(address_type: Address::POSTAL,
                            line_1: Faker::Address.street_address,
                            line_2: Faker::Address.secondary_address,
                            suburb: Faker::Address.city,
                            state: 'NSW',
                            postcode: '2001',
                            country: Faker::Address.country)
      @address = @user.addresses.first
    end

    it "has a valid factory" do
      expect(build(:address, addressable: @user)).to be_valid
    end

    it { should respond_to (:line_1) }
    it { should respond_to (:line_2) }
    it { should respond_to (:suburb) }
    it { should respond_to (:state) }
    it { should respond_to (:postcode) }
    it { should respond_to (:country) }
    it { should respond_to (:address_type) }

    describe "#address_type" do
      it "can have a postal address" do
        address = build(:address, address_type: 0)
        expect(address.address_type).to eq(Address::POSTAL)
        expect(address).to be_valid
      end  

      it "can have a physical address" do
        address = build(:address, address_type: 1)
        expect(address.address_type).to eq(Address::PHYSICAL)
        expect(address).to be_valid
      end

      it "can have a billing address" do
        address = build(:address, address_type: 2)
        expect(address.address_type).to eq(Address::BILLING)
        expect(address).to be_valid
      end

      it "can have a delivery address" do
        address = build(:address, address_type: 3)
        expect(address.address_type).to eq(Address::DELIVERY)
        expect(address).to be_valid
      end

      it "cannot have an invalid address_type" do
        address = build(:address, address_type: 4)
        expect(address).to be_invalid
      end
    end

    describe "Australian states" do
      it "should list Australian states" do
        expect(Address::AUSTRALIAN_STATES).to eq(['ACT', 'NSW', 'NT', 'QLD', 'SA', 'TAS', 'VIC', 'WA'])
      end

      it "should have a state if country code is Australia" do
        @address.state = ""
        @address.country = 'Australia'
        expect(@address).to be_invalid
      end

      it "should have a state if no country code is specified" do
        @address.state = ""
        @address.country = ''
        expect(@user).to be_invalid
      end

      it "should have a valid Australian State if country code is Australia" do
        invalid_states = ['SA1', 'XX']
        invalid_states.each do |inv_state|
          @address.state = inv_state
          @address.country = 'Australia'
          expect(@user).to be_invalid
        end
      end

      it "should have a valid Australian State if no country is specified" do
        invalid_states = ['XX', ""]
        invalid_states.each do |inv_state|
          @address.state = inv_state
          @address.country = ""
          expect(@user).to be_invalid
        end
      end

      it "may have an unknown state if country is not Australia" do
        @address.state = 'XX'
        @address.country = 'Peru'
        expect(@user).to be_valid
      end
    end

    describe "#line_1" do
      it "should have something in line_1" do
        @address.line_1 = ""
        expect(@user).to be_invalid
      end
    end

    describe "#suburb" do
      it "must have a suburb" do
        @address.suburb = ""
        expect(@user).to be_invalid
      end
    end

    describe "#postcode" do
      it "should strip spaces before and after postal codes" do
        [' 0123', ' 6363 ', '7111 ', '8888'].each do |postcode|
          address = create(:address, country: 'Australia', state: 'ACT', postcode: postcode)
          expect(address.postcode).to eq(postcode.strip)
        end
      end

      it "should ensure postcode is 4 digits when country is Australia" do
        ['123 ', ' 456', '12345', '12C4'].each do |postcode|
          @address.country = 'Australia'
          @address.postcode = postcode
          expect(@user).to be_invalid
        end
      end

      it "should not validate postcode when country is not Australia" do
        ['3521 RG', '55555'].each do |postcode|
          @address.country = 'England'
          @address.postcode = postcode
          expect(@user).to be_valid
        end
      end
    end

    describe "#addressable" do
      it "should link address and user" do
        @user.save!
        @address = @user.addresses.first
        expect(@address.addressable).to eq(@user)
      end
    end

    describe "Auto-correcting minor format errors" do
      it "should correct 'Australia' when alternative format was used" do
        ['Au', 'aust ', 'Aust.', 'australia '].each do |country|
          address = create(:address, country: country)
          expect(address.country).to eq('Australia')
        end
      end

      it "should reject invalid states when country is Australia" do
        ['southaustralia', 'tas mania', 'unknown'].each do |state|
          address = build(:address, country: 'Australia', state: state)
          expect(address).to be_invalid
        end
      end

      it "should correct minor errors in state format when country is Australia" do
        correct_states = ['NSW', 'NSW', 'NSW', 'QLD', 'WA', 'ACT', 'TAS', 'VIC']
        ['NSW', ' NSw', 'nsw  ', 'qld', ' wa ', 'Act', 'TASMANIA', 'vic'].each_with_index do |state, index|
          address = create(:address, country: ' australia ', state: state)
          expect(address.state).to eq(correct_states[index])
        end
      end

      it "should strip spaces before and after suburbs and title the suburb" do
        ['  Acacia ridge', 'acacia ridge '].each do |suburb|
          address = create(:address, country: 'Australia', suburb: suburb)
          expect(address.suburb).to eq('Acacia Ridge')
        end
      end

      it "should not validate states when country is not Australia" do
        address = create(:address, country: 'China', state: 'china state', suburb: 'chong ', postcode: '  123')
        expect(address.state).to eq('china state')
        expect(address.suburb).to eq('Chong')
        expect(address.postcode).to eq('123')
      end
    end
  end

  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:enquiry) }
    it { should respond_to(:line_1) }
    it { should respond_to(:line_2) }
    it { should respond_to(:suburb) }
    it { should respond_to(:state) }
    it { should respond_to(:postcode) }
    it { should respond_to(:country) }
    it { should respond_to(:address_type) }
    it { should respond_to(:addressable) }
  end
end
