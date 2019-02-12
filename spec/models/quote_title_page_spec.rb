require 'spec_helper'

describe QuoteTitlePage do
  describe "validations" do
    it "has a valid factory" do
      expect(build(:quote_title_page)).to be_valid
    end

    it { should validate_presence_of :quote_id }
    it { should validate_presence_of :title }
    it { should validate_presence_of :image_1 }
    it { should validate_presence_of :image_2 }

    context "image_1" do
      it { should have_attached_file(:image_1) }
      it { should validate_attachment_content_type(:image_1).
                  allowing('image/jpeg', 'image/png', 'image/gif').
                  rejecting('application/pdf', 'text/plain', 'text/xml', 'application/msword') }
      it { should validate_attachment_size(:image_1).
                    less_than(5.megabytes) }
    end

    context "image_2" do
      it { should have_attached_file(:image_2) }
      it { should validate_attachment_content_type(:image_2).
                  allowing('image/jpeg', 'image/png', 'image/gif').
                  rejecting('application/pdf', 'text/plain', 'text/xml', 'application/msword') }
      it { should validate_attachment_size(:image_2).
                    less_than(5.megabytes) }
    end
  end

  describe "associations" do
    it { should belong_to(:quote) }
  end
end
