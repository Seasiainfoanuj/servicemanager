require 'spec_helper'

describe SpInvoice do
  describe "validations" do
    let(:sp_invoice) { build(:sp_invoice, invoice_number: 'I765') }

    it "has a valid factory" do
      expect(sp_invoice).to be_valid
    end

    it { should validate_presence_of :job_id }
    it { should validate_presence_of :job_type }

    it "should a valid resource name" do
      expect(sp_invoice.resource_name).to eq('SP Invoice I765')
    end

    context "upload" do
      it { should have_attached_file(:upload) }
      it { should validate_attachment_content_type(:upload).
                  allowing('image/jpeg', 'image/png', 'image/gif', 'application/pdf', 'application/msword', 'text/plain', 'text/xml') }
      it { should validate_attachment_size(:upload).
                    less_than(15.megabytes) }
    end
  end

  describe "associations" do
    it { should belong_to(:job) }
    it { should have_many(:notes).dependent(:destroy) }
  end
end
