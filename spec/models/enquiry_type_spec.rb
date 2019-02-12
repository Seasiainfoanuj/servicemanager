require 'spec_helper'

describe EnquiryType do
  describe "validations" do
    it "has a valid factory" do
      expect(create(:enquiry_type)).to be_valid
    end

    it { should validate_presence_of :name }
    it { should validate_uniqueness_of :name }
    it { should validate_presence_of :slug }
    it { should validate_uniqueness_of :slug }
  end

  describe "associations" do
    it { should have_many(:enquiries) }
  end

  describe "EnquiryType.hire_enquiry" do
    before do
      @enquiry_type = create(:enquiry_type, name: 'Hire - Lease', slug: 'hire')
    end

    it "should return the Enquiry Type for Hire" do
      expect(EnquiryType.hire_enquiry).to eq(@enquiry_type)
    end  
  end

  describe "#hire_enquiry?" do
    before do
      @enquiry_type1 = create(:enquiry_type, name: 'Hire / Lease', slug: 'hire')
      @enquiry_type2 = create(:enquiry_type, name: 'Almost Hiring', slug: 'pseudo-hire')
    end

    it "should identify a Hire Enquiry" do
      expect(@enquiry_type1.hire_enquiry?).to eq(true)
      expect(@enquiry_type2.hire_enquiry?).to eq(false)
    end
  end
end
