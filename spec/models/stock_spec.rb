require "spec_helper"

describe Stock do
  describe "validations" do
    it "has a valid factory" do
      expect(build(:stock)).to be_valid
    end

    it "is valid with model, supplier, stock_number, vin_number, engine_number, transmission, and eta" do
      vehicle_model = create(:vehicle_model)
      supplier = create(:user, :supplier)
      stock = create(:stock,
        model: vehicle_model,
        supplier: supplier,
        stock_number: "STOCK-1",
        vin_number: Faker::Number.number(17),
        engine_number: Faker::Lorem.characters(20).upcase,
        transmission: "manual",
        eta: Date.today
      )
      expect(stock).to be_valid
      expect(stock.resource_name).to match(/Stock Item STOCK-[0-9]/)
    end

    it { should validate_presence_of :supplier_id }
    it { should validate_presence_of :vehicle_model_id }
    it { should validate_presence_of :stock_number }

    it { should ensure_length_of(:vin_number).is_equal_to(17) }

    describe "returns make as string" do
      context "if vehicle model present" do
        it "returns make" do
          make = create(:vehicle_make, name: "ferrari")
          model = create(:vehicle_model, vehicle_make_id: make.id, name: "modena", year: 2013)
          stock = build(:stock, vehicle_model_id: model.id)

          expect(stock.make).to eq make
        end
      end

      context "if vehicle model not present" do
        it "returns nil" do
          stock = build(:stock, vehicle_model_id: nil)
          expect(stock.make).to eq nil
        end
      end
    end

    describe "returns name as string" do
      context "if vehicle model present" do
        it "returns year, make and model" do
          make = create(:vehicle_make, name: "ferrari")
          model = create(:vehicle_model, vehicle_make_id: make.id, name: "modena")
          stock = build(:stock, vehicle_model_id: model.id)

          expect(stock.name).to eq "ferrari modena"
        end
      end

      context "if vehicle model not present" do
        it "defaults to placeholder string" do
          stock = build(:stock, vehicle_model_id: nil)
          expect(stock.name).to eq "Stock Item"
        end
      end
    end

    describe "returns number as string" do
      context "if stock number present" do
        it "returns stock number" do
          stock = build(:stock, stock_number: "STOCK-1")
          expect(stock.number).to eq "STOCK-1"
        end
      end

      context "if missing stock number" do
        it "returns nil" do
          stock = build(:stock, stock_number: nil)
          expect(stock.number).to eq nil
        end
      end
    end

    it "returns eta_date_field in user friendly format" do
      stock = create(:stock, eta: Date.today)
      expect(stock.eta_date_field).to eq Date.today.strftime("%d/%m/%Y")
    end

    it "parses eta_date_field in db friendly format" do
      date = Date.today.strftime("%d/%m/%Y")
      stock = create(:stock, eta_date_field: date)
      expect(stock.eta_date_field).to eq date
    end
  end

  describe "associations" do
    it { should belong_to(:model).class_name('VehicleModel').with_foreign_key('vehicle_model_id') }
    it { should belong_to(:supplier).class_name('User') }
    it { should have_many(:notes).dependent(:destroy) }
    it { should have_one(:stock_request) }
  end
end
