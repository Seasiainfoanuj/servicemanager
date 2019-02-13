require 'spec_helper'

describe NoteUpload do
  describe "validations" do
    it "has a valid factory" do
      expect(create(:note_upload)).to be_valid
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
    it { should belong_to(:note) }
  end
end
