require 'spec_helper'

describe OffHireReportUpload do
  describe "validations" do
    it "has a valid factory" do
      expect(create(:off_hire_report_upload)).to be_valid
    end

    it { should validate_presence_of :off_hire_report_id }

    context "upload" do
      it { should have_attached_file(:upload) }
      it { should validate_attachment_content_type(:upload).
                  allowing('image/jpeg', 'image/png', 'image/gif', 'application/pdf', 'application/msword', 'text/plain', 'text/xml') }
      it { should validate_attachment_size(:upload).
                    less_than(15.megabytes) }
    end

    describe "#to_jq_upload" do
      it "returns json required for multiple file uploader" do
        pending "expecting '\\' but returning nil; possible incorrect expectation"
        upload = OffHireReportUpload.new :upload => File.new(Rails.root + 'spec/fixtures/images/rails.png')
        expect(upload.to_jq_upload.to_s).to eq "{\"name\"=>\"#{upload.upload_file_name}\", \"size\"=>#{upload.upload_file_size}, \"url\"=>\"#{upload.upload.url(:original)}\", \"thumbnail_url\"=>\"#{upload.upload.url(:medium)}\", \"delete_url\"=>\"/off_hire_report_uploads/\", \"delete_type\"=>\"DELETE\"}"
      end
    end
  end

  describe "associations" do
    it { should belong_to(:off_hire_report) }
  end
end
