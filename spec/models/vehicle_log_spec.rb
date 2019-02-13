require "spec_helper"

describe VehicleLog do
  describe "validations" do
    let(:vehicle_log) { build(:vehicle_log) }

    it "has a valid factory" do
      expect(vehicle_log).to be_valid
      expect(vehicle_log.resource_name).to eq("Vehicle Log for vehicle: #{vehicle_log.vehicle.resource_name}")
    end

    describe "#flagged?" do
      it "returns flagged" do
        log = create(:vehicle_log, flagged: true)
        expect(log.flagged?).to eq true
      end
    end

    describe "#created" do
      it "returns created_at in human friendly format" do
        log = create(:vehicle_log)
        expect(log.created).to eq log.created_at.in_time_zone(Time.zone).strftime("%d/%m/%Y %I:%M %p")
      end
    end

    describe "#updated" do
      it "returns updated_at in human friendly format" do
        log = create(:vehicle_log)
        expect(log.updated).to eq log.updated_at.in_time_zone(Time.zone).strftime("%d/%m/%Y %I:%M %p")
      end
    end
  end

  describe "associations" do
    it { should belong_to(:vehicle) }
    it { should belong_to(:workorder) }
    it { should belong_to(:service_provider).class_name('User') }
    it { should have_many(:log_uploads) }
    it { should have_many(:notes).dependent(:destroy) }
  end
end
