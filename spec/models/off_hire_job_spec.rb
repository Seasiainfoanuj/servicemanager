require 'spec_helper'

describe OffHireJob do
  describe "validations" do
    let(:off_hire_job) { build(:off_hire_job) }

    it "has a valid factory" do
      expect(off_hire_job).to be_valid
    end

    it { should validate_presence_of :off_hire_report_id }
    it { should validate_presence_of :invoice_company_id }
    it { should validate_presence_of :service_provider_id }
    it { should validate_uniqueness_of :uid }

    it "should a valid resource name" do
      expect(off_hire_job.resource_name).to match(/Off Hire Job hj-/)
    end

    describe "#sched_datetime" do
      it "returns sched_time in user friendly format" do
        Timecop.travel(2020, 1, 1, 12, 0, 0) do
          time = Date.today
          off_hire_job = create(:off_hire_job, sched_time: time)
          expect(off_hire_job.sched_datetime).to eq time.strftime("%Y-%m-%d %H:%M")
        end
      end
    end

    describe "#sched_date_field" do
      it "returns sched_time date only in user friendly format" do
        Timecop.travel(2020, 1, 1, 12, 0, 0) do
          time = Date.today
          off_hire_job = create(:off_hire_job, sched_time: time)
          expect(off_hire_job.sched_date_field).to eq time.strftime("%d/%m/%Y")
        end
      end

      it "parses sched_date_field in db friendly format" do
        Timecop.travel(2020, 1, 1, 12, 0, 0) do
          date = Date.today.strftime("%d/%m/%Y")
          off_hire_job = create(:off_hire_job, sched_date_field: date, sched_time_field: date)
          expect(off_hire_job.sched_date_field).to eq date
        end
      end
    end

    describe "#sched_time_field" do
      it "returns sched_time time only in user friendly format" do
        Timecop.travel(2020, 1, 1, 12, 0, 0) do
          time = Date.today
          off_hire_job = create(:off_hire_job, sched_time: time)
          expect(off_hire_job.sched_time_field).to eq time.strftime("%I:%M %p")
        end
      end

      it "parses sched_time_field in db friendly format" do
        Timecop.travel(2020, 1, 1, 12, 0, 0) do
          time = Time.now.strftime("%l:%M %p")
          off_hire_job = create(:off_hire_job, sched_time_field: time)
          expect(off_hire_job.sched_time_field).to match /\d+:\d+\s[AP]M/
          #expect(off_hire_job.sched_time_field).to eq time
        end
      end
    end

    describe "#etc_datetime" do
      it "returns etc in user friendly format" do
        Timecop.travel(2020, 1, 1, 12, 0, 0) do
          time = Date.today
          off_hire_job = create(:off_hire_job, etc: time)
          expect(off_hire_job.etc_datetime).to eq time.strftime("%Y-%m-%d %H:%M")
        end
      end
    end

    describe "#etc_date_field" do
      it "returns etc date only in user friendly format" do
        Timecop.travel(2020, 1, 1, 12, 0, 0) do
          time = Date.today
          off_hire_job = create(:off_hire_job, etc: time)
          expect(off_hire_job.etc_date_field).to eq time.strftime("%d/%m/%Y")
        end
      end
    end

    it "parses etc_date_field in db friendly format" do
      Timecop.travel(2020, 1, 1, 12, 0, 0) do
        date = Date.today.strftime("%d/%m/%Y")
        off_hire_job = create(:off_hire_job, etc_date_field: date, etc_time_field: date)
        expect(off_hire_job.etc_date_field).to eq date
      end
    end
  end

  describe "#etc_time_field" do
    it "returns etc time only in user friendly format" do
      Timecop.travel(2020, 1, 1, 12, 0, 0) do
        time = Date.today
        off_hire_job = create(:off_hire_job, etc: time)
        expect(off_hire_job.etc_time_field).to eq time.strftime("%I:%M %p")
      end
    end

    it "parses etc_time_field in db friendly format" do
      Timecop.travel(2020, 1, 1, 12, 0, 0) do
        time = Time.now
        off_hire_job = create(:off_hire_job, etc_time_field: time.strftime("%l:%M %p"))
        expect(off_hire_job.etc_time_field).to match /\d+:\d+\s[AP]M/
        #expect(off_hire_job.etc_time_field).to eq time.strftime("%l:%M %p")
      end
    end

    describe "#self.send_reminders_for_tomorrow" do
      it "should add email to delay queue" do
        expectedCount = Delayed::Job.count + 2
        off_hire_job = create(:off_hire_job, sched_time: 1.day.from_now)
        off_hire_job = create(:off_hire_job, sched_time: 1.day.from_now, status: "cancelled")
        off_hire_job = create(:off_hire_job, sched_time: 1.day.from_now, status: "complete")
        OffHireJob.send_reminders_for_tomorrow
        expect(Delayed::Job.count).to eq expectedCount
      end

      it "should add subscribers email to delay queue" do
        expectedCount = Delayed::Job.count + 4
        off_hire_job = create(:off_hire_job, sched_time: 1.day.from_now)
        subscriber_1 = create(:user, :customer)
        subscriber_2 = create(:user, :customer)
        off_hire_job.subscribers << [subscriber_1, subscriber_2]
        OffHireJob.send_reminders_for_tomorrow
        expect(Delayed::Job.count).to eq expectedCount
      end
    end

    describe "#self.send_reminders_for_next_week" do
      it "adds email to delay queue" do
        expectedCount = Delayed::Job.count + 2
        off_hire_job = create(:off_hire_job, sched_time: 1.week.from_now)
        off_hire_job = create(:off_hire_job, sched_time: 1.week.from_now, status: "cancelled")
        off_hire_job = create(:off_hire_job, sched_time: 1.week.from_now, status: "complete")
        OffHireJob.send_reminders_for_next_week
        expect(Delayed::Job.count).to eq expectedCount
      end

      it "should add subscribers email to delay queue" do
        expectedCount = Delayed::Job.count + 4
        off_hire_job = create(:off_hire_job, sched_time: 1.week.from_now)
        subscriber_1 = create(:user, :customer)
        subscriber_2 = create(:user, :customer)
        off_hire_job.subscribers << [subscriber_1, subscriber_2]
        OffHireJob.send_reminders_for_next_week
        expect(Delayed::Job.count).to eq expectedCount
      end
    end
  end

  describe "associations" do
    it { should belong_to(:off_hire_report) }
    it { should belong_to(:invoice_company) }
    it { should belong_to(:service_provider).class_name('User') }
    it { should belong_to(:manager).class_name('User') }
    it { should have_many(:uploads).class_name('OffHireJobUpload') }
    it { should accept_nested_attributes_for(:uploads).allow_destroy(true) }

    it { should have_many(:job_subscribers) }
    it { should have_many(:subscribers).through(:job_subscribers).source(:user) }

    it { should have_many(:notes).dependent(:destroy) }
    it { should have_one(:sp_invoice) }
    it { should accept_nested_attributes_for(:sp_invoice).allow_destroy(true) }
  end
end
