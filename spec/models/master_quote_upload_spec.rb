require 'spec_helper'

describe MasterQuoteUpload do
  let(:master_quote) { create(:master_quote) }

  describe "validations" do
    it "has a valid factory" do
      expect(create(:master_quote_upload)).to be_valid
    end

    it { should validate_presence_of :master_quote_id }

    context "upload" do
      it { should have_attached_file(:upload) }
      it { should validate_attachment_content_type(:upload).
                  allowing('image/jpeg', 'image/png', 'image/gif', 'application/pdf') }
      it { should validate_attachment_size(:upload).
                    less_than(10.megabytes) }
    end
  end

  describe "associations" do
    it { should belong_to(:master_quote) }
  end

  describe "scope enquiries" do
    before do
      2.times { create(:master_quote_upload, master_quote: master_quote) }
    end

    it "should access all documents for the vehicle" do
      expect(master_quote.attachments.count).to eq(2)
    end
  end

end
