require "spec_helper"

describe EnquiryPresenter, type: :presenter do
  let (:customer) { create(:user, :customer, first_name: 'Viola', last_name: 'Flemming', email: 'viola@me.com', representing_company: nil, client_attributes: { client_type: 'person'})}

  describe "presenting enquiry calculations" do
    before do
      create_enquiry_types
      @enquiry = create_enquiry
      view_context = double('View context')
      @presenter = EnquiryPresenter.new(@enquiry, view_context)
    end

    it "presents enquiry_types" do
      expect(@presenter.options_for_enquiry_types).to include(['Bus Enquiry', @enq_type_1.id])
      expect(@presenter.options_for_enquiry_types).to include(['General Enquiry', @enq_type_2.id])
      expect(@presenter.options_for_enquiry_types).to include(['Motorhome Enquiry', @enq_type_3.id])
    end

    it "presents selected customer" do
      expect(@enquiry.user.id).to eq(customer.id)
    end

  end

  def create_enquiry
    Enquiry.create(
      enquiry_type_id: @enq_type_1.id,
      first_name: 'Harry',
      last_name: 'Cilliers',
      email: 'harry.cilliers@example.com',
      phone: '0537543543',
      details: 'This is my enquiry',
      user: customer
      )  
  end

  def create_enquiry_types
    @enq_type_1 = EnquiryType.create(name: 'Bus Enquiry', slug: 'bus')
    @enq_type_2 = EnquiryType.create(name: 'General Enquiry', slug: 'general')
    @enq_type_3 = EnquiryType.create(name: 'Motorhome Enquiry', slug: 'motorhome')
    @enq_type_4 = FactoryGirl.create(:enquiry_type, name: 'Sales', slug: 'sales')
  end

end