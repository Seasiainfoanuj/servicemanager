require 'spec_helper'

describe SalesOrderMilestone do
  describe "validations" do
    it "has a valid factory" do
      expect(build(:sales_order_milestone)).to be_valid
    end

    it { should validate_presence_of :description }

    describe "#milestone_datetime" do
      after do
        Timecop.return
      end
      
      it "returns the date in the format %Y-%m-%d %H:%M" do
        today = Date.today
        Timecop.freeze(today) do
          sales_order_milestone = create(:sales_order_milestone, milestone_date: today)
          expect(sales_order_milestone.milestone_datetime).to eq today.strftime("%Y-%m-%d %H:%M")
        end
      end
    end

    describe "#milestone_date_field" do
      after do
        Timecop.return
      end
      
      it "returns the date in the format %d/%m/%Y" do
        today = Date.today
        Timecop.freeze(today) do
          sales_order_milestone = create(:sales_order_milestone, milestone_date: today)
          expect(sales_order_milestone.milestone_date_field).to eq today.strftime("%d/%m/%Y")
        end
      end

      it "parses date in format %d/%m/%Y " do
        today = Date.today
        Timecop.freeze(today) do
          sales_order_milestone = create(:sales_order_milestone, milestone_date_field: today.strftime("%d/%m/%Y"), milestone_time_field: today.strftime("%I:%M %p"))
          expect(sales_order_milestone.milestone_date.strftime("%a, %e %b %Y")).to eq today.strftime("%a, %e %b %Y")
        end
      end
    end

    describe "#milestone_time_field" do
      after do
        Timecop.return
      end
      
      it "returns the time in the format %I:%M %p" do
        today = Date.today
        Timecop.freeze(today) do
          sales_order_milestone = create(:sales_order_milestone, milestone_date: today)
          expect(sales_order_milestone.milestone_time_field).to eq today.strftime("%I:%M %p")
        end
      end
    end

    describe "validate convert_to_datetime" do
      let!(:milestone) { build(:sales_order_milestone) }
      let!(:time_now) { Time.now }

      context "if milestone_date_field and milestone_time_field present" do
        before do
          milestone.update_attributes(
            milestone_date_field: time_now.strftime("%d/%m/%Y"),
            milestone_time_field: time_now.strftime("%I:%M %p")
          )
        end

        it "passes validation and sets datetime" do
          expect(milestone.save).to be_truthy
        end
      end

      context "if milestone_date present" do
        before do
          milestone.update_attributes(
            milestone_date: time_now,
            milestone_date_field: nil,
            milestone_time_field: nil
          )
        end

        it "passes validation" do
          expect(milestone.milestone_date).to eq(time_now)
          expect(milestone.save).to be_truthy
        end
      end

      context "if milestone_date not present" do
        before do
          milestone.update_attributes(
            milestone_date: nil,
            milestone_date_field: nil,
            milestone_time_field: nil
          )
        end

        it "fails to validate" do
          expect(milestone.save).to be_falsey
        end
      end
    end
  end

  describe "associations" do
    it { should belong_to(:sales_order) }
  end
end

