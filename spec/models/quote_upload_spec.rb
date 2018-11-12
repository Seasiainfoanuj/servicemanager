require 'spec_helper'

describe QuoteUpload do
  describe "validations" do
    it "has a valid factory" do
      expect(create(:quote_upload)).to be_valid
    end

    it { should validate_presence_of :quote_id }

    context "upload" do
      it { should have_attached_file(:upload) }
      it { should validate_attachment_content_type(:upload).
                  allowing('image/jpeg', 'image/png', 'image/gif', 'application/pdf') }
      it { should validate_attachment_size(:upload).
                    less_than(10.megabytes) }
    end

    describe "#to_jq_upload" do
      it "returns json required for multiple file uploader" do
        pending "expecting '\\' but returning nil; possible incorrect expectation"
        upload = QuoteUpload.new :upload => File.new(Rails.root + 'spec/fixtures/images/rails.png')
        expect(upload.to_jq_upload.to_s).to eq "{\"name\"=>\"#{upload.upload_file_name}\", \"size\"=>#{upload.upload_file_size}, \"url\"=>\"#{upload.upload.url(:original)}\", \"thumbnail_url\"=>\"#{upload.upload.url(:medium)}\", \"delete_url\"=>\"/quote_uploads/\", \"delete_type\"=>\"DELETE\"}"
      end
    end
  end

  describe "associations" do
    it { should belong_to(:quote) }
  end
end
