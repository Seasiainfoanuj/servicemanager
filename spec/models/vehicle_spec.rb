require "spec_helper"

describe Vehicle do
  describe "validations" do
    let(:supplier) { create(:user, :supplier) }
    let(:owner) { create(:user, :customer) }
    let(:make)  { create(:vehicle_make, name: "ferrari") }
    let(:vehicle_model) { create(:vehicle_model, make: make, name: "modena") }

    before do
      @vehicle = build(:vehicle, supplier: supplier, owner: owner, model: vehicle_model)
    end

    it "has a valid factory" do
      expect(@vehicle).to be_valid
    end

    it "is valid with vehicle_model, supplier, owner, build_number, vehicle_number, vin_number, vehicle_number, engine_number, transmission, mod_plate, odometer_reading, seating_capacity, rego_number, rego_due_date, order_number, invoice_number, kit_number, notes, created_at, updated_at, license_required, exclude_from_schedule, delivery_date, class_type and call_sign" do
      vehicle = create(:vehicle,
        model: vehicle_model,
        model_year: 2013,
        supplier: supplier,
        owner: owner,
        build_number: "BUILD-1",
        vehicle_number: "vehicle-1",
        vin_number: Faker::Number.number(17),
        vehicle_number: "VEHICLE-1",
        engine_number: Faker::Number.number(17),
        transmission: "Manual",
        mod_plate: Faker::Lorem.words,
        odometer_reading: "200,000",
        seating_capacity: 12,
        rego_number: "SDF-123",
        rego_due_date: Date.today,
        order_number: "DD000123",
        invoice_number: "INV00123",
        kit_number: "KIT-1",
        license_required: "C,R",
        exclude_from_schedule: true,
        delivery_date: 12.days.from_now,
        class_type: "Bus",
        call_sign: Faker::Lorem.words,
        build_date: Date.today - 5.days,
        colour: 'Olive Green',
        engine_type: 'ABC93S88',
        status: 'on_offer',
        status_date: Date.today
      )
      expect(vehicle).to be_valid
      expect(vehicle.resource_name).to eq("Vehicle: #{vehicle.name}")
    end

    it { should validate_uniqueness_of :vin_number }
    it { should ensure_length_of(:vin_number).is_equal_to(17) }
    it { should respond_to(:tags) }
    it { should respond_to(:vehicle_number) }
    it { should respond_to(:fuel_type) }
    it { should respond_to(:usage_status) }
    it { should respond_to(:operational_status) }
    it { should respond_to(:model_year) }

    describe "#make" do
      context "if vehicle model present" do
        it "returns make" do
          expect(@vehicle.make).to eq make
        end
      end
    end

    describe "#model" do
      context "if vehicle model not present" do
        it "regards the vehicle as invalid" do
          @vehicle.model = nil
          expect(@vehicle).to be_invalid
        end
      end
    end

    describe "#name" do
      context "if vehicle model present" do
        it "returns make and model" do
          expect(@vehicle.name).to eq "2013 ferrari modena"
        end
      end
    end

    describe "#ref_name" do
      context "if vehicle vehicle_number, model, callsign, seating_capacity, rego_number and vin_number present" do
        it "returns ref_name with (-) seperators" do
          vehicle = build(:vehicle,
            model: vehicle_model,
            vehicle_number: "VEHICLE-1",
            call_sign: "CALLSIGN-1",
            seating_capacity: 12,
            rego_number: "SDF-123",
            vin_number: "12345678123456781"
          )
          expect(vehicle.ref_name).to eq "VEHICLE-1 CALLSIGN-1 - 2013 ferrari modena - [Seat Capacity 12] - [REGO SDF-123] - [VIN 12345678123456781]"
        end
      end

      context "if vehicle vehicle_number not present" do
        it "returns ref_name with (-) seperators" do
          vehicle = build(:vehicle,
            model: vehicle_model,
            vehicle_number: nil,
            call_sign: "CALLSIGN-1",
            seating_capacity: 12,
            rego_number: "SDF-123",
            vin_number: "12345678123456781"
          )
          expect(vehicle.ref_name).to eq "CALLSIGN-1 - 2013 ferrari modena - [Seat Capacity 12] - [REGO SDF-123] - [VIN 12345678123456781]"
        end
      end

      context "if vehicle callsign not present" do
        it "returns ref_name with (-) seperators" do
          vehicle = build(:vehicle,
            model: vehicle_model,
            vehicle_number: "VEHICLE-1",
            call_sign: nil,
            seating_capacity: 12,
            rego_number: "SDF-123",
            vin_number: "12345678123456781"
          )
          expect(vehicle.ref_name).to eq "VEHICLE-1 - 2013 ferrari modena - [Seat Capacity 12] - [REGO SDF-123] - [VIN 12345678123456781]"
        end
      end

      context "if vehicle seating_capacity not present" do
        it "returns ref_name with (-) seperators" do
          vehicle = build(:vehicle,
            model: vehicle_model,
            vehicle_number: "VEHICLE-1",
            call_sign: "CALLSIGN-1",
            seating_capacity: nil,
            rego_number: "SDF-123",
            vin_number: "12345678123456781"
          )
          expect(vehicle.ref_name).to eq "VEHICLE-1 CALLSIGN-1 - 2013 ferrari modena - [REGO SDF-123] - [VIN 12345678123456781]"
        end
      end

      context "if vehicle rego_number not present" do
        it "returns ref_name with (-) seperators" do
          vehicle = build(:vehicle,
            model: vehicle_model,
            vehicle_number: "VEHICLE-1",
            call_sign: "CALLSIGN-1",
            seating_capacity: 12,
            rego_number: nil,
            vin_number: "12345678123456781"
          )
          expect(vehicle.ref_name).to eq "VEHICLE-1 CALLSIGN-1 - 2013 ferrari modena - [Seat Capacity 12] - [VIN 12345678123456781]"
        end
      end

      context "if vehicle vin_number not present" do
        it "returns ref_name with (-) seperators" do
          vehicle = build(:vehicle,
            model: vehicle_model,
            vehicle_number: "VEHICLE-1",
            call_sign: "CALLSIGN-1",
            seating_capacity: 12,
            rego_number: "SDF-123",
            vin_number: nil
          )
          expect(vehicle.ref_name).to eq "VEHICLE-1 CALLSIGN-1 - 2013 ferrari modena - [Seat Capacity 12] - [REGO SDF-123]"
        end
      end

      context "if only name present"  do
        it "returns name" do
          @vehicle.vehicle_number = nil
          @vehicle.call_sign = nil
          @vehicle.seating_capacity = nil
          @vehicle.rego_number = nil
          @vehicle.vin_number = nil
          expect(@vehicle.ref_name).to eq "2013 ferrari modena"
        end
      end
    end

    describe "#number_int" do
      context "if vehicle number present" do
        it "returns vehicle number stripped of everything but numbers" do
          vehicle = build(:vehicle, vehicle_number: "VEHICLE-1")
          expect(vehicle.number_int).to eq 1
        end
      end

      context "if missing vehicle number" do
        it "returns 0" do
          vehicle = build(:vehicle, vehicle_number: nil)
          expect(vehicle.number_int).to eq 0
        end
      end
    end

    describe "#resource" do
      before(:each) do
        @vehicle = build(:vehicle, model: vehicle_model, vehicle_number: "VEHICLE-1", call_sign: "CALLSIGN-1", rego_number: "ASD-123")
        @admin = create(:user, :admin)
        @service_provider = create(:user, :service_provider)
      end

      context "if current user role is admin" do
        it "returns vehicle details and link as html string" do
          expect(@vehicle.resource(@admin)).to eq "<span class='label label-satblue'>VEHICLE-1</span> <span class='label label-green'>CALLSIGN-1</span> <span class='label'>ASD-123</span><br><a href='/vehicles/#{@vehicle.id}'>#{@vehicle.name}</a>"
        end
      end

      context "if current user role is service provider" do
        it "returns vehicle details as html string" do
          expect(@vehicle.resource(@service_provider)).to eq "<span class='label label-satblue'>VEHICLE-1</span> <span class='label label-green'>CALLSIGN-1</span> <span class='label'>ASD-123</span><br>#{@vehicle.name}"
        end
      end
    end

    describe "#status" do
      before do
        @valid_statuses = Vehicle::STATUSES
        @invalid_statuses = ['draft', 'Sold']
        @vehicle = build(:vehicle)
      end

      it "should accept valid statusses" do
        @valid_statuses.each do |status|
          @vehicle.status = status
          expect(@vehicle).to be_valid
        end
      end

      it "should reject invalid statusses" do
        @invalid_statuses.each do |status|
          @vehicle.status = status
          expect(@vehicle).to be_invalid
        end
      end

      it "should present a formatted status" do
        vehicle = build(:vehicle, status: 'on_offer')
        expect(vehicle.status_name).to eq('On Offer')
      end

      it "returns 'unknown' when no status exists" do
        vehicle = FactoryGirl.create(:vehicle)
        vehicle.status = ""
        expect(vehicle.status_name).to eq('unknown')
      end

      it "should initialise a new vehicle with status and status_date" do
        vehicle = build(:vehicle, supplier: supplier, owner: owner)
        expect(vehicle.status).to eq("available")
        expect(vehicle.status_date).to eq(Date.today)
      end
    end

    describe "#status_date" do
      it "creates a new Vehicle with a status date of today" do
        @vehicle = create(:vehicle, supplier: supplier, owner: owner)
        expect(@vehicle.status_date).to eq(Date.today)
      end
    end

    describe "#build_date" do
      it "updates the build_date_field" do
        @vehicle = build(:vehicle, supplier: supplier, owner: owner, build_date_field: "31/03/2016" )
        expect(@vehicle.build_date_field).to eq('31/03/2016')
      end
    end

    describe "#fuel_type" do
      it "has diesel as the default fuel_type" do
        expect(@vehicle.fuel_type).to eq("diesel")
      end
    end

    describe "knowing when the vehicle may be sold" do
      before do
        @vehicle1 = build(:vehicle, status: 'available')
        @vehicle2 = build(:vehicle, status: 'sold')
      end

      it "may be sold when the status is 'available'" do
        expect(@vehicle1.may_be_sold?).to eq(true)
      end

      it "may be not be sold when the status is 'sold'" do
        expect(@vehicle2.may_be_sold?).to eq(false)
      end
    end

    it "returns hire_resource as html string for hire schedule calendar" do
      vehicle = build(:vehicle, vehicle_number: "VEHICLE-1", seating_capacity: 12)
      expect(vehicle.hire_resource).to eq "<span class='label label-satblue'>VEHICLE-1</span> <span class='label'>12 Seats</span><br><a href='/vehicles/#{vehicle.id}'>#{vehicle.name}</a>"
    end

    it "returns rego_due_date_field in user friendly format" do
      vehicle = create(:vehicle, rego_due_date: Date.today)
      expect(vehicle.rego_due_date_field).to eq Date.today.strftime("%d/%m/%Y")
    end

    it "parses rego_due_date_field in db friendly format" do
      date = Date.today.strftime("%d/%m/%Y")
      vehicle = create(:vehicle, rego_due_date_field: date)
      expect(vehicle.rego_due_date_field).to eq date
    end

    it "returns delivery_date_field in user friendly format" do
      vehicle = create(:vehicle, delivery_date: Date.today)
      expect(vehicle.delivery_date_field).to eq Date.today.strftime("%d/%m/%Y")
    end

    it "parses delivery_date_field in db friendly format" do
      date = Date.today.strftime("%d/%m/%Y")
      vehicle = create(:vehicle, delivery_date_field: date)
      expect(vehicle.delivery_date_field).to eq date
    end

    it "should ensure has hire_details" do
      expect{create(:vehicle)}.to change(HireVehicle, :count).by(1)

      hire_vehicle = create(:hire_vehicle, vehicle: nil)

      vehicle1 = create(:vehicle, vin_number: "1234567812345678a")
      vehicle2 = create(:vehicle, hire_details: hire_vehicle, vin_number: "1234567812345678b")

      expect(vehicle1.hire_details).to eq HireVehicle.last
      expect(vehicle2.hire_details).to_not eq HireVehicle.last
      expect(vehicle2.hire_details).to eq hire_vehicle
    end

    describe "returns hire_vehicle? as boolean" do
      context "if hire_details present" do
        it "return true if hire_vehicle.status = active" do
          hire_vehicle = create(:hire_vehicle, active: true)
          vehicle = create(:vehicle, hire_details: hire_vehicle, vin_number: "1234567812345678a")
          expect(vehicle.hire_vehicle?).to eq true
        end
      end

      context "if hire_details not present" do
        it "return false" do
          vehicle = create(:vehicle)
          expect(vehicle.hire_vehicle?).to eq false
        end
      end
    end

    describe "scope by vin" do
      before do
        @vehicle1 = create(:vehicle, supplier: supplier, owner: owner, vin_number: "1234511222123456a")
        @vehicle2 = create(:vehicle, supplier: supplier, owner: owner, vin_number: "1234511122123456b")
        @vehicle3 = create(:vehicle, supplier: supplier, owner: owner, vin_number: "1234522333123456c")
        @filtered_vehicles = Vehicle.by_vin('22123')
      end

      it "filter by partial vin_number" do
        expect(@filtered_vehicles.count).to eq(2)
        expect(@filtered_vehicles).not_to include(@vehicle3)
        expect(@filtered_vehicles).to include(@vehicle2)
      end
    end

  end

  describe "associations" do
    it { should belong_to(:model).class_name('VehicleModel').with_foreign_key('vehicle_model_id') }
    it { should belong_to(:supplier).class_name('User') }
    it { should belong_to(:owner).class_name('User') }
    it { should have_many(:log_entries).class_name('VehicleLog') }
    it { should have_many(:workorders) }
    it { should have_many(:hire_agreements) }
    it { should have_many(:vehicle_uploads) }
    it { should have_many(:notes).dependent(:destroy) }
    it { should have_one(:hire_details).class_name('HireVehicle') }
    it { should have_one(:build) }

    it { should have_many(:vehicle_schedule_views) }
    it { should have_many(:images) }
    it { should have_many(:notifications) }
    it { should have_many(:schedule_views).through(:vehicle_schedule_views) }

    it { should accept_nested_attributes_for(:hire_details).allow_destroy(true) }
  end
end
