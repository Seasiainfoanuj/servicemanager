require "spec_helper"

describe HireVehicle do
  describe "validations" do
    it "has a valid factory" do
      expect(build(:vehicle)).to be_valid
    end

    it "is valid with vehicle, daily_km_allowance, daily_rate, excess_km_rate and active boolean" do
      vehicle = create(:vehicle)
      hire_vehicle = create(:hire_vehicle,
        vehicle: vehicle,
        daily_km_allowance: 300,
        daily_rate: 120.00,
        excess_km_rate: 3.50,
        active: true
      )
    end

    describe "returns make as string" do
      context "if vehicle model present" do
        it "returns make" do
          make = create(:vehicle_make, name: "ferrari")
          model = create(:vehicle_model, vehicle_make_id: make.id, name: "modena", year: 2013)
          vehicle = build(:vehicle, vehicle_model_id: model.id)
          hire_vehicle = build(:hire_vehicle, vehicle: vehicle)
          
          expect(hire_vehicle.make).to eq make
        end
      end

      context "if vehicle model not present" do
        it "returns nil" do
          vehicle = build(:vehicle, vehicle_model_id: nil)
          hire_vehicle1 = build(:hire_vehicle, vehicle: vehicle)
          hire_vehicle2 = build(:hire_vehicle, vehicle: nil)
          
          expect(hire_vehicle1.make).to eq nil
          expect(hire_vehicle2.make).to eq nil
        end
      end
    end

    describe "returns name as string" do
      context "if vehicle model present" do
        it "returns make and model" do
          make = create(:vehicle_make, name: "ferrari")
          model = create(:vehicle_model, vehicle_make_id: make.id, name: "modena")
          vehicle = build(:vehicle, vehicle_model_id: model.id)
          hire_vehicle = build(:hire_vehicle, vehicle: vehicle)
          
          expect(hire_vehicle.name).to eq "ferrari modena"
        end
      end

      context "if vehicle model not present" do
        it "defaults to empty string" do
          vehicle = build(:vehicle, vehicle_model_id: nil)
          hire_vehicle1 = build(:hire_vehicle, vehicle: vehicle)
          hire_vehicle2 = build(:hire_vehicle, vehicle: nil)

          expect(hire_vehicle1.name).to eq ""
          expect(hire_vehicle2.name).to eq ""
        end
      end
    end

    describe "returns ref_name as string" do
      context "if vehicle present" do
        it "returns vehicle ref_name as string" do
          make = create(:vehicle_make, name: "ferrari")
          model = create(:vehicle_model, vehicle_make_id: make.id, name: "modena", year: 2013)
          vehicle = build(:vehicle,
            vehicle_model_id: model.id,
            vehicle_number: "VEHICLE-1",
            call_sign: "CALLSIGN-1",
            seating_capacity: 12,
            rego_number: "SDF-123",
            vin_number: "12345678"
          )
          hire_vehicle = build(:hire_vehicle, vehicle: vehicle)
          expect(hire_vehicle.ref_name).to eq vehicle.ref_name
        end
      end

      context "if vehicle not present" do
        it "defaults to empty string" do
          hire_vehicle = build(:hire_vehicle, vehicle: nil)
          expect(hire_vehicle.ref_name).to eq ""
        end
      end
    end
  end

  describe "associations" do
    it { should belong_to(:vehicle) }
  end
end