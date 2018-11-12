require 'spec_helper'

describe Build do
  describe "validations" do
    let(:build) { FactoryGirl.build(:build) }

    it "has a valid factory" do
      expect(build).to be_valid
    end

    it { should validate_uniqueness_of :vehicle_id }
    it { should validate_uniqueness_of :number }

    it "should a valid resource name" do
      expect(build.resource_name).to match(/Build MA-/)
    end

    describe "#start_time" do
      context "if no build orders" do
        it "returns nil" do
          build = create(:build)
          expect(build.start_time).to eq nil
        end
      end

      context "if build orders present" do
        it "returns scheduled time of first build order" do
          time = Time.now
          Timecop.freeze(time) do
            build = create(:build)
            build_order = create(:build_order, build: build)
            expect(build.start_time.to_s).to eq build_order.sched_time.to_s
          end
          Timecop.return
        end
      end
    end

    describe "#etc" do
      context "if no build orders" do
        it "returns nil" do
          build = create(:build)
          expect(build.etc).to eq nil
        end
      end

      context "if build orders present" do
        it "returns etc time of last build order" do
          time = Time.now
          Timecop.freeze(time) do
            build = create(:build)
            build_order = create(:build_order, build: build)
            expect(build.etc.to_s).to eq build_order.etc.to_s
          end
          Timecop.return
        end
      end
    end

    describe "#status" do
      context "if pending build orders present" do
        it "returns 'in progress' as string" do
          build = create(:build)
          build_order = create(:build_order, build: build, status: "complete")
          build_order = create(:build_order, build: build, status: "pending")
          expect(build.status).to eq "in progress"
        end
      end

      context "if all build orders complete" do
        it "returns 'complete' as string" do
          build = create(:build)
          build_order = create(:build_order, build: build, status: "complete")
          build_order = create(:build_order, build: build, status: "complete")
          expect(build.status).to eq "complete"
        end
      end
    end
  end

  describe "associations" do
    it { should belong_to(:vehicle) }
    it { should belong_to(:manager).class_name("User") }
    it { should belong_to(:quote) }
    it { should have_many(:build_orders) }
    it { should have_many(:uploads).class_name("BuildUpload") }
    it { should have_many(:notes).dependent(:destroy) }

    it { should have_one(:sales_order) }
    it { should have_one(:specification).class_name("BuildSpecification") }
  end
end
