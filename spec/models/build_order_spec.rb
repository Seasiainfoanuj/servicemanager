require 'spec_helper'

describe BuildOrder do
  describe "validations" do
    let(:build_order) { build(:build_order, name: "Mercedes") }

    it "has a valid factory" do
      expect(build_order).to be_valid
    end

    it { should validate_presence_of :build_id }
    it { should validate_presence_of :invoice_company_id }
    it { should validate_presence_of :name }

    it "should a valid resource name" do
      expect(build_order.resource_name).to match(/Build MA-.*, Build Order Mercedes/)
    end

    describe "#sched_datetime" do
      after do
        Timecop.return
      end

      it "returns the date in the format %Y-%m-%d %H:%M" do
        today = Date.today
        Timecop.freeze(today) do
          build_order = create(:build_order, sched_time: today)
          expect(build_order.sched_datetime).to eq today.strftime("%Y-%m-%d %H:%M")
        end
      end
    end

    describe "#sched_date_field" do
      after do
        Timecop.return
      end
      
      it "returns the date in the format %d/%m/%Y" do
        today = Date.today
        Timecop.freeze(today) do
          build_order = create(:build_order, sched_time: today)
          expect(build_order.sched_date_field).to eq today.strftime("%d/%m/%Y")
        end
      end

      it "parses date in format %d/%m/%Y " do
        today = Date.today
        Timecop.freeze(today) do
          build_order = create(:build_order, sched_date_field: today.strftime("%d/%m/%Y"), sched_time_field: today.strftime("%I:%M %p"))
          expect(build_order.sched_time.strftime("%a, %e %b %Y")).to eq today.strftime("%a, %e %b %Y")
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
          build_order = create(:build_order, sched_time: today)
          expect(build_order.sched_time_field).to eq today.strftime("%I:%M %p")
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
          build_order = create(:build_order, etc: today)
          expect(build_order.etc_datetime).to eq today.strftime("%Y-%m-%d %H:%M")
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
          build_order = create(:build_order, etc: today)
          expect(build_order.etc_date_field).to eq today.strftime("%d/%m/%Y")
        end
      end

      it "parses date in format %d/%m/%Y " do
        today = Date.today
        Timecop.freeze(today) do
          build_order = create(:build_order, etc_date_field: today.strftime("%d/%m/%Y"), etc_time_field: today.strftime("%I:%M %p"))
          expect(build_order.etc.strftime("%a, %e %b %Y")).to eq today.strftime("%a, %e %b %Y")
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
          build_order = create(:build_order, etc: today)
          expect(build_order.etc_time_field).to eq today.strftime("%I:%M %p")
        end
      end
    end

    describe "#self.send_reminders_for_tomorrow" do
      it "should add email to delay queue" do
        expectedCount = Delayed::Job.count + 2
        build_order = create(:build_order, sched_time: 1.day.from_now)
        build_order = create(:build_order, sched_time: 1.day.from_now, status: "cancelled")
        build_order = create(:build_order, sched_time: 1.day.from_now, status: "complete")
        BuildOrder.send_reminders_for_tomorrow
        expect(Delayed::Job.count).to eq expectedCount
      end

      it "should add subscribers email to delay queue" do
        expectedCount = Delayed::Job.count + 4
        build_order = create(:build_order, sched_time: 1.day.from_now)
        subscriber_1 = create(:user, :customer)
        subscriber_2 = create(:user, :customer)
        build_order.subscribers << [subscriber_1, subscriber_2]
        BuildOrder.send_reminders_for_tomorrow
        expect(Delayed::Job.count).to eq expectedCount
      end
    end

    describe "#self.send_reminders_for_next_week" do
      it "adds email to delay queue" do
        expectedCount = Delayed::Job.count + 2
        build_order = create(:build_order, sched_time: 1.week.from_now)
        build_order = create(:build_order, sched_time: 1.week.from_now, status: "cancelled")
        build_order = create(:build_order, sched_time: 1.week.from_now, status: "complete")
        BuildOrder.send_reminders_for_next_week
        expect(Delayed::Job.count).to eq expectedCount
      end

      it "should add subscribers email to delay queue" do
        expectedCount = Delayed::Job.count + 4
        build_order = create(:build_order, sched_time: 1.week.from_now)
        subscriber_1 = create(:user, :customer)
        subscriber_2 = create(:user, :customer)
        build_order.subscribers << [subscriber_1, subscriber_2]
        BuildOrder.send_reminders_for_next_week
        expect(Delayed::Job.count).to eq expectedCount
      end
    end
  end

  describe "associations" do
    it { should belong_to(:build) }
    it { should belong_to(:invoice_company) }
    it { should belong_to(:service_provider).class_name("User") }
    it { should belong_to(:manager).class_name("User") }
    it { should have_many(:build_order_uploads) }

    it { should have_many(:job_subscribers) }
    it { should have_many(:subscribers).through(:job_subscribers).source(:user) }

    it { should have_many(:notes).dependent(:destroy) }
    it { should have_one(:sp_invoice) }
    it { should accept_nested_attributes_for(:sp_invoice).allow_destroy(true) }
  end
end
