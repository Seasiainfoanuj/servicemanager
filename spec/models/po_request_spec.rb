require 'spec_helper'

describe PoRequest do
  describe "validations" do
    let(:po_request) { build(:po_request) }

    it "has a valid factory" do
      expect(po_request).to be_valid
    end

    it { should validate_presence_of :uid }
    it { should validate_uniqueness_of :uid }
    it { should validate_presence_of :status }
    it { should validate_presence_of :service_provider_id }
    it { should validate_presence_of :vehicle_make }
    it { should validate_presence_of :vehicle_model }
    it { should validate_presence_of :vehicle_vin_number }
    it { should ensure_length_of(:vehicle_vin_number).is_equal_to(17) }
    it "should a valid resource name" do
      expect(po_request.resource_name).to match(/PO Request sr-/)
    end

    describe "#to_param" do
      it "returns parameterized uid" do
        po_request = create(:po_request)
        expect(po_request.to_param).to eq po_request.uid.parameterize
      end
    end

    describe "#flagged?" do
      it "returns flagged" do
        po_request = create(:po_request, flagged: true)
        expect(po_request.flagged?).to eq true
      end
    end

    describe "#sched_date_field" do
      after do
        Timecop.return
      end
      
      it "returns the date in the format %d/%m/%Y" do
        today = Date.today
        Timecop.freeze(today) do
          po_request = create(:po_request, sched_time: today)
          expect(po_request.sched_date_field).to eq today.strftime("%d/%m/%Y")
        end
      end

      it "parses date in format %d/%m/%Y " do
        today = Date.today
        Timecop.freeze(today) do
          po_request = create(:po_request, sched_date_field: today.strftime("%d/%m/%Y"), sched_time_field: today.strftime("%I:%M %p"))
          expect(po_request.sched_time.strftime("%a, %e %b %Y")).to eq today.strftime("%a, %e %b %Y")
        end
      end
    end

    describe "#sched_time_field" do
      after do
        Timecop.return
      end
      
      it "returns the time in the format %I:%M %p" do
        today = Date.today
        Timecop.freeze(today) do
          po_request = create(:po_request, sched_time: today)
          expect(po_request.sched_time_field).to eq today.strftime("%I:%M %p")
        end
      end
    end

    describe "#etc_datetime" do
      after do
        Timecop.return
      end
      
      it "returns the date in the format %Y-%m-%d %H:%M" do
        today = Date.today
        Timecop.freeze(today) do
          po_request = create(:po_request, etc: today)
          expect(po_request.etc_datetime).to eq today.strftime("%Y-%m-%d %H:%M")
        end
      end
    end

    describe "#etc_date_field" do
      after do
        Timecop.return
      end
      
      it "returns the date in the format %d/%m/%Y" do
        today = Date.today
        Timecop.freeze(today) do
          po_request = create(:po_request, etc: today)
          expect(po_request.etc_date_field).to eq today.strftime("%d/%m/%Y")
        end
      end

      it "parses date in format %d/%m/%Y " do
        today = Date.today
        Timecop.freeze(today) do
          po_request = create(:po_request, etc_date_field: today.strftime("%d/%m/%Y"), etc_time_field: today.strftime("%I:%M %p"))
          expect(po_request.etc.strftime("%a, %e %b %Y")).to eq today.strftime("%a, %e %b %Y")
        end
      end
    end

    describe "#etc_time_field" do
      after do
        Timecop.return
      end
      
      it "returns the time in the format %I:%M %p" do
        today = Date.today
        Timecop.freeze(today) do
          po_request = create(:po_request, etc: today)
          expect(po_request.etc_time_field).to eq today.strftime("%I:%M %p")
        end
      end
    end
  end

  describe "associations" do
    it { should belong_to(:vehicle) }
    it { should belong_to(:service_provider).class_name('User') }

    it { should have_many(:uploads).class_name("PoRequestUpload") }
    it { should accept_nested_attributes_for(:uploads).allow_destroy(true) }

    it { should have_many(:notes).dependent(:destroy) }
  end
end
