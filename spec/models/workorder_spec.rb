require "spec_helper"

describe Workorder do
  describe "validations" do
    let(:workorder) { build(:workorder) }

    it "has a valid factory" do
      expect(workorder).to be_valid
      expect(workorder.resource_name).to eq("Workorder for vehicle: #{workorder.vehicle.resource_name}")
    end

    it { should validate_presence_of :vehicle_id }
    it { should validate_presence_of :invoice_company_id }
    it { should validate_presence_of :service_provider_id }
    it { should validate_presence_of :workorder_type_id }

    describe "#type_name" do
      context "if type is present" do
        it "returns type.name as string" do
          workorder_type = create(:workorder_type, name: "nap")
          workorder = create(:workorder, type: workorder_type)
          expect(workorder.type_name).to eq "nap"
        end
      end

      context "if type is missing" do
        it "returns a default value as string" do
          workorder = create(:workorder)
          workorder.type = nil
          expect(workorder.type_name).to eq "Workorder"
        end
      end
    end

    describe "#sched_datetime" do
      after do
        Timecop.return
      end
      
      it "returns the date in the format %Y-%m-%d %H:%M" do
        today = Date.today
        Timecop.freeze(today) do
          workorder = create(:workorder, sched_time: today)
          expect(workorder.sched_datetime).to eq today.strftime("%Y-%m-%d %H:%M")
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
          workorder = create(:workorder, sched_time: today)
          expect(workorder.sched_date_field).to eq today.strftime("%d/%m/%Y")
        end
      end

      it "parses date in format %d/%m/%Y " do
        today = Date.today
        Timecop.freeze(today) do
          workorder = create(:workorder, sched_date_field: today.strftime("%d/%m/%Y"), sched_time_field: today.strftime("%I:%M %p"))
          expect(workorder.sched_time.strftime("%a, %e %b %Y")).to eq today.strftime("%a, %e %b %Y")
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
          workorder = create(:workorder, sched_time: today)
          expect(workorder.sched_time_field).to eq today.strftime("%I:%M %p")
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
          workorder = create(:workorder, etc: today)
          expect(workorder.etc_datetime).to eq today.strftime("%Y-%m-%d %H:%M")
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
          workorder = create(:workorder, etc: today)
          expect(workorder.etc_date_field).to eq today.strftime("%d/%m/%Y")
        end
      end

      it "parses date in format %d/%m/%Y " do
        today = Date.today
        Timecop.freeze(today) do
          workorder = create(:workorder, etc_date_field: today.strftime("%d/%m/%Y"), etc_time_field: today.strftime("%I:%M %p"))
          expect(workorder.etc.strftime("%a, %e %b %Y")).to eq today.strftime("%a, %e %b %Y")
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
          workorder = create(:workorder, etc: today)
          expect(workorder.etc_time_field).to eq today.strftime("%I:%M %p")
        end
      end
    end

    describe "#recurring?" do
      after do
        Timecop.return
      end
      
      context "if is_recurring is true" do
        it "returns 'Yes' as string" do
        today = Date.today
        Timecop.freeze(today) do
            workorder = create(:workorder, is_recurring: true)
            expect(workorder.recurring?).to eq "Yes"
          end
        end
      end

      context "if is_recurring is false" do
        it "returns 'Not Recurring' as string" do
          today = Timecop.freeze(Date.today) do
            workorder = create(:workorder, is_recurring: false)
            expect(workorder.recurring?).to eq "Not Recurring"
          end
        end
      end
    end

    describe "#recurring_period_field" do
      it "sets the recurring period" do
        workorder = create(:workorder, is_recurring: true)
        period = rand(3..12)
        workorder.recurring_period_field = period
        expect(workorder.recurring_period).to eq period
      end

      it "reads the recurring period" do
        workorder = create(:workorder, is_recurring: true)
        period = rand(3..12)
        workorder.recurring_period = period
        expect(workorder.recurring_period_field).to eq period
      end
    end

    describe "#recurring_period_humanize" do
      context ".recurring_period is 1" do
        it "returns 'Day'" do
          workorder = create(:workorder, recurring_period: 1)
          expect(workorder.recurring_period_humanize).to eq "1 Day"
        end
      end

      context ".recurring_period is greater than 1" do
        it "returns 'Days'" do
          workorder = create(:workorder, recurring_period: 5)
          expect(workorder.recurring_period_humanize).to eq "5 Days"
        end
      end
    end

    describe "#next_workorder_date" do
      after do
        Timecop.return
      end
      
      it "returns sched_time + recurring_period.days" do
        today = Date.today
        Timecop.freeze(today) do
          workorder = create(:workorder, sched_time: Date.today, recurring_period: 4)
          expect(workorder.next_workorder_date.to_date).to eq Date.today + 4.days
        end
      end
    end

    describe "#next_workorder_etc" do
      it "returns sched_time + recurring_period.days" do
        workorder = create(:workorder, etc: Date.today, recurring_period: 4)
        expect(workorder.next_workorder_etc.to_date).to eq Date.today + 4.days
      end
    end

    describe "#self.send_reminders_for_tomorrow" do
      it "should add email to delay queue" do
        expectedCount = Delayed::Job.count + 3
        workorder = create(:workorder, sched_time: 1.day.from_now)
        workorder = create(:workorder, sched_time: 1.day.from_now, status: "cancelled")
        workorder = create(:workorder, sched_time: 1.day.from_now, status: "complete")
        Workorder.send_reminders_for_tomorrow
        expect(Delayed::Job.count).to eq expectedCount
      end

      it "should add subscribers email to delay queue" do
        expectedCount = Delayed::Job.count + 5
        workorder = create(:workorder, sched_time: 1.day.from_now)
        subscriber_1 = create(:user, :customer)
        subscriber_2 = create(:user, :customer)
        workorder.subscribers << [subscriber_1, subscriber_2]
        Workorder.send_reminders_for_tomorrow
        expect(Delayed::Job.count).to eq expectedCount
      end
    end

    describe "#self.send_reminders_for_next_week" do
      it "adds email to delay queue" do
        expectedCount = Delayed::Job.count + 3
        workorder = create(:workorder, sched_time: 1.week.from_now)
        workorder = create(:workorder, sched_time: 1.week.from_now, status: "cancelled")
        workorder = create(:workorder, sched_time: 1.week.from_now, status: "complete")
        Workorder.send_reminders_for_next_week
        expect(Delayed::Job.count).to eq expectedCount
      end

      it "should add subscribers email to delay queue" do
        expectedCount = Delayed::Job.count + 5
        workorder = create(:workorder, sched_time: 1.week.from_now)
        subscriber_1 = create(:user, :customer)
        subscriber_2 = create(:user, :customer)
        workorder.subscribers << [subscriber_1, subscriber_2]
        Workorder.send_reminders_for_next_week
        expect(Delayed::Job.count).to eq expectedCount
      end
    end

    describe "associations" do
      it { should belong_to(:vehicle) }
      it { should belong_to(:invoice_company) }
      it { should belong_to(:type).class_name('WorkorderType') }
      it { should belong_to(:service_provider).class_name('User') }
      it { should belong_to(:customer).class_name('User') }
      it { should belong_to(:manager).class_name('User') }
      it { should have_many(:workorder_uploads) }

      it { should have_many(:job_subscribers) }
      it { should have_many(:subscribers).through(:job_subscribers).source(:user) }

      it { should have_many(:notes).dependent(:destroy) }

      it { should have_many(:messages) }
      it { should have_one(:vehicle_log) }

      it { should have_one(:sp_invoice) }
      it { should accept_nested_attributes_for(:sp_invoice).allow_destroy(true) }
    end
  end
end
