require "spec_helper"

describe Licence do
  describe "validations" do
    it "has a valid factory" do
      expect(build(:licence)).to be_valid
    end

    it "is valid with user, number, state_of_issue and expiry_date" do
      user = create(:user, :customer)
      licence = create(:licence,
        user: user,
        number: "12345678",
        state_of_issue: "QLD",
        expiry_date: 10.years.from_now
      )

      expect(licence).to be_valid
    end

    it { should validate_presence_of :user_id }

    context "upload" do
      it { should have_attached_file(:upload) }
      it { should validate_attachment_content_type(:upload).
                  allowing('image/jpeg', 'image/png', 'image/gif', 'application/pdf').
                  rejecting('text/plain', 'text/xml', 'application/msword') }
      it { should validate_attachment_size(:upload).
                    less_than(10.megabytes) }
    end

    describe "#expiry_date_field" do
      it "returns expiry_date in user friendly format" do
        licence = create(:licence, expiry_date: Date.today)
        expect(licence.expiry_date_field).to eq Date.today.strftime("%d/%m/%Y")
      end

      it "parses expiry_date_field in db friendly format" do
        date = Date.today.strftime("%d/%m/%Y")
        licence = create(:licence, expiry_date_field: date)
        expect(licence.expiry_date_field).to eq date
      end
    end
  end

  describe "associations" do
    it { should belong_to(:user) }
  end
end