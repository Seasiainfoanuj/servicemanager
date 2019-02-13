require 'spec_helper'

describe HireEnquiry do
  describe "validations" do
    let(:enquiry_type) { FactoryGirl.create(:enquiry_type, name: 'Hire / Lease') }
    let(:customer) { FactoryGirl.create(:user, :customer) }

    before do
      @enquiry = create(:enquiry, enquiry_type: enquiry_type, user: customer)
      @hire_enquiry = build(:hire_enquiry, enquiry: @enquiry)
    end

    subject { @hire_enquiry }

    it "has a valid factory" do
      expect(@hire_enquiry).to be_valid
    end

    it { should respond_to(:hire_start_date) }
    it { should respond_to(:duration_unit) }    
    it { should respond_to(:units) }    
    it { should respond_to(:number_of_vehicles) }    
    it { should respond_to(:delivery_required) }    
    it { should respond_to(:delivery_location) }    
    it { should respond_to(:transmission_preference) }    
    it { should respond_to(:minimum_seats) }    
    it { should respond_to(:ongoing_contract) }    
    it { should respond_to(:special_requirements) }    

    it { should validate_presence_of(:hire_start_date).with_message('A Hire Start Date must be provided') }
    it { should validate_presence_of :transmission_preference }
    it { should validate_presence_of :duration_unit }

    describe "#duration_unit" do
      it "should not have an invalid duration_unit" do
        [nil, 'ages'].each do |unit|
          @hire_enquiry.duration_unit = unit
          expect(@hire_enquiry).to be_invalid
        end
      end
    end

    describe "#transmission_preference" do
      it "should not have an invalid transmission_preference" do
        [nil, '', 'straight'].each do |preference|
          @hire_enquiry.transmission_preference = preference
          expect(@hire_enquiry).to be_invalid
        end
      end
    end

    describe "#hire_start_date" do
      it "returns the date in the format %d/%m/%Y" do
        today = Date.today
        @hire_enquiry.hire_start_date = today
        @enquiry.hire_enquiry = @hire_enquiry
        @enquiry.save
        expect(@hire_enquiry.reload.hire_start_date_field).to eq today.strftime("%d/%m/%Y")
      end

      # it "parses date in format %d/%m/%Y " do
      #   today = Date.today
      #   @hire_enquiry.hire_start_date_field = today.strftime("%d/%m/%Y")
      #   expect(@hire_enquiry.hire_start_date).to eq(today)
      # end
    end

    describe "#delivery_location" do
      it "regards delivery_location as optional if delivery_required is false" do
        [nil, "", "Somewhere"].each do |place|
          @hire_enquiry.delivery_required = false
          @hire_enquiry.delivery_location = place
          expect(@hire_enquiry).to be_valid
        end
      end

      it "regards delivery_location as mandatory if delivery_required" do
        @hire_enquiry.delivery_required = true
        @hire_enquiry.delivery_location = ""
        expect(@hire_enquiry).to be_invalid
      end
    end

    describe "#number_of_vehicles" do
      it "should be positive" do
        [-1, 0].each do |number|
          @hire_enquiry.number_of_vehicles = number
          expect(@hire_enquiry).to be_invalid
        end
      end
    end

    describe "#end_date" do
      before do
        @hire_enquiry.hire_start_date = Date.today
        @expected_conditions = [ 
          {duration_unit: 'days', units: 10, result: Date.today + 10.days},
          {duration_unit: 'weeks', units: 3, result: Date.today + 3.weeks},
          {duration_unit: 'months', units: 2, result: Date.today + 2.months},
          {duration_unit: 'years', units: 1, result: Date.today + 1.year}
        ]
      end

      it "calculates the end date correctly" do
        @expected_conditions.each do |conditions|
          @hire_enquiry.duration_unit = conditions[:duration_unit]
          @hire_enquiry.units = conditions[:units]
          expect(@hire_enquiry.end_date).to eq(conditions[:result])
        end
      end
    end
  end  

  describe "associations" do
    it { should belong_to(:enquiry) }
  end
end