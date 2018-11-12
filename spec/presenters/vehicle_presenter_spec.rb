require "spec_helper"

describe VehiclePresenter, type: :presenter do
  let (:supplier)     { create(:user, :supplier, first_name: 'Ben', last_name: 'Booysen', email: 'ben@me.com', representing_company: nil, client_attributes: { client_type: 'person'}) }
  let (:customer)     { create(:user, :customer, first_name: 'Viola', last_name: 'Flemming', email: 'viola@me.com', representing_company: nil, client_attributes: { client_type: 'person'})}
  let!(:vehicle_make) { create(:vehicle_make, name: "Isuzu") }
  let(:vehicle_model) { create(:vehicle_model, make: vehicle_make, name: "modena", year: 2013) }
  let!(:vehicle1)      { create(:vehicle, vehicle_number: "VEHICLE-1", model: vehicle_model, supplier: supplier, owner: customer) }

  describe "presenting vehicle calculations" do
    before do
      view_context = double('View context')
      @presenter    = VehiclePresenter.new(vehicle1, view_context)
    end

    it "presents transmission_types" do
      expect(@presenter.transmission_types).to eq(["Automatic", "Manual", "Automated Manual", "Unknown"])
    end

    it "presents options_for_suppliers" do
      expect(@presenter.options_for_suppliers).to eq([['Ben Booysen - ben@me.com', supplier.id]])
    end

    it "presents the supplier id of the vehicle if available" do
      expect(@presenter.selected_supplier).to eq(supplier.id)
    end

    it "presents a dropdown list to choose the vehicle owner" do
      expect(@presenter.options_for_owners).to include(['Ben Booysen - ben@me.com', supplier.id])
      expect(@presenter.options_for_owners).to include(['Viola Flemming - viola@me.com', customer.id])
    end

    it "presents the owner id of the vehicle if available" do
      expect(@presenter.selected_owner).to eq(customer.id)
    end

  end

end