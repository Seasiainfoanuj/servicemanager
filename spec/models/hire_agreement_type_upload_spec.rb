require 'spec_helper'

describe HireAgreementTypeUpload do
  describe "validations" do
    it "has a valid factory" do
      expect(create(:hire_agreement_type_upload)).to be_valid
    end

    it { should validate_presence_of :hire_agreement_type_id }

    context "upload" do
      it { should have_attached_file(:upload) }
      it { should validate_attachment_content_type(:upload).
                  allowing('image/jpeg', 'image/png', 'image/gif', 'application/pdf', 'application/msword', 'text/plain', 'text/xml') }
      it { should validate_attachment_size(:upload).
                    less_than(15.megabytes) }
    end

    describe "#to_jq_upload" do
      it "returns json required for mutiple file uploader" do
        pending "expecting '\\' but returning nil; possible incorrect expectation"
        upload = HireAgreementTypeUpload.new :upload => File.new(Rails.root + 'spec/fixtures/images/rails.png')
        expect(upload.to_jq_upload.to_s).to eq "{\"name\"=>\"#{upload.upload_file_name}\", \"size\"=>#{upload.upload_file_size}, \"url\"=>\"#{upload.upload.url(:original)}\", \"thumbnail_url\"=>\"#{upload.upload.url(:medium)}\", \"delete_url\"=>\"/hire_agreement_type_uploads/\", \"delete_type\"=>\"DELETE\"}"
      end
    end
  end

  describe "associations" do
    it { should belong_to(:hire_agreement_type) }
  end
end
