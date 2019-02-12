require 'spec_helper'

describe MasterQuoteSpecificationSheet do
  let(:master_quote) { create(:master_quote) }

  describe "validations" do
    it "has a valid factory" do
      expect(create(:master_quote_specification_sheet)).to be_valid
    end

    it { should validate_presence_of :master_quote_id }

    context "upload" do
      it { should have_attached_file(:upload) }
      it { should validate_attachment_content_type(:upload).
                  allowing('application/pdf') }
      it { should validate_attachment_size(:upload).
                    less_than(10.megabytes) }
    end
  end

  describe "associations" do
    it { should belong_to(:master_quote) }
  end
end
