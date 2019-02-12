require "spec_helper"

describe InvoiceCompany do
  describe "validations" do
    it "has a valid factory" do
      expect(create(:invoice_company)).to be_valid
    end

    it { should validate_presence_of :name }
    it { should validate_presence_of :logo }
    it { should validate_presence_of :phone}
    it { should validate_presence_of :address_line_1}
    it { should validate_presence_of :suburb}
    it { should validate_presence_of :state}
    it { should validate_presence_of :postcode}
    it { should validate_presence_of :country}
    it { should validate_presence_of :accounts_admin_id}
    it { should validate_presence_of :slug }
    it { should validate_uniqueness_of :slug }

    context "logo" do
      it { should have_attached_file(:logo) }
      it { should validate_attachment_content_type(:logo).
                  allowing('image/jpeg', 'image/png').
                  rejecting('text/plain', 'text/xml') }
      it { should validate_attachment_size(:logo).
                    less_than(5.megabytes) }
    end
  end

  describe "InvoiceCompany.hire_company" do
    before do
      @invoice_company = create(:invoice_company, name: BUS4X4_HIRE_COMPANY_NAME)
    end

    it "should return the InvoiceCompany for Hire" do
      expect(InvoiceCompany.hire_company).to eq(@invoice_company)
    end  
  end

  describe "website_address" do
    let(:company_with_website) { create :invoice_company, website: "google.com" }
    let(:company_with_no_website) { create :invoice_company, website: nil }

    it "should return fallback website for company without website" do
      expect(company_with_no_website.website).to eq("www.bus4x4.com.au")
    end

    it "should return company's website" do
      expect(company_with_website.website).to eq("google.com")
    end
  end

  describe "associations" do
    it { should have_many(:quotes).dependent(:restrict_with_error) }
    it { should have_many(:stock_requests).dependent(:restrict_with_error) }
    it { should have_many(:workorders).dependent(:restrict_with_error) }
    it { should have_many(:build_orders).dependent(:restrict_with_error) }
    it { should have_many(:off_hire_jobs).dependent(:restrict_with_error) }
    it { should belong_to(:accounts_admin).class_name('User') }
    it { should have_many(:employees).class_name("User").with_foreign_key('employer_id') }
  end
end
