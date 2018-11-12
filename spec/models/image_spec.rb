require "spec_helper"

describe Image do
  describe "validations" do

    it "has a valid factory" do
      expect(build(:document)).to be_valid
      expect(build(:photo)).to be_valid
    end

    it { should validate_presence_of :name }
    it { should have_attached_file(:image) }

    it { should validate_attachment_content_type(:image).allowing('image/jpeg', 'image/jpeg', 'image/png', 
                          'image/gif', 'application/pdf', 'application/msword', 'text/plain', 'text/xml') }

    it { should validate_attachment_size(:image).less_than(10.megabytes) }
  end

  describe "associations" do
    it { should belong_to(:imageable) }
    it { should belong_to(:document_type) }
    it { should belong_to(:photo_category) }
  end

  describe "scope enquiries" do

    before do
      @vehicle = create(:vehicle)
      2.times { create(:document, imageable: @vehicle) }
      3.times { create(:photo, imageable: @vehicle) }
    end

    it "should access all documents for the vehicle" do
      expect(@vehicle.images.documents.count).to eq(2)
      expect(@vehicle.images.photos.count).to eq(3)
    end
  end

end

