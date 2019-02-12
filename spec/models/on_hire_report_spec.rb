require 'spec_helper'

describe OnHireReport do
  describe "validations" do
    it "has a valid factory" do
      expect(build(:on_hire_report)).to be_valid
    end

    it { should validate_presence_of :hire_agreement_id }
    it { should validate_presence_of :user_id }

    describe "#report_datetime" do
      it "returns report_time in user friendly format" do
        on_hire_report = create(:on_hire_report, report_time: Date.today)
        expect(on_hire_report.report_datetime).to eq Date.today.strftime("%Y-%m-%d %H:%M")
      end
    end

    describe "#report_date_field" do
      it "returns report_time date only in user friendly format" do
        on_hire_report = create(:on_hire_report, report_time: Date.today)
        expect(on_hire_report.report_date_field).to eq Date.today.strftime("%d/%m/%Y")
      end

      it "parses report_date_field in db friendly format" do
        date = Date.today.strftime("%d/%m/%Y")
        on_hire_report = create(:on_hire_report, report_date_field: date)
        expect(on_hire_report.report_date_field).to eq date
      end
    end

    describe "#report_time_field" do
      it "returns report_time time only in user friendly format" do
        on_hire_report = create(:on_hire_report, report_time: Date.today)
        expect(on_hire_report.report_time_field).to eq Date.today.strftime("%I:%M %p")
      end

      it "parses report_time_field in db friendly format" do
        time = Date.today.strftime("%I:%M %p")
        on_hire_report = create(:on_hire_report, report_time_field: time)
        expect(on_hire_report.report_time_field).to eq time
      end
    end
  end

  describe "associations" do
    it { should belong_to(:hire_agreement) }
    it { should belong_to(:user) }
    it { should have_many(:uploads).class_name('OnHireReportUpload') }

    it { should accept_nested_attributes_for(:uploads).allow_destroy(true) }
  end
end
