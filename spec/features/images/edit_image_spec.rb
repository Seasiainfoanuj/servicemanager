require "spec_helper"

feature "New Image page" do

  before(:each) do
    @admin = create(:user, :admin)
    @supplier = create(:user, :supplier)
    create(:document_type, name: 'Modification Certificate')
    create(:document_type, name: 'Pre Delivery Inspection Sheet')
    @vehicle = create(:vehicle, vehicle_number: "VEHICLE-1", supplier: @supplier)
    @image = create(:document, imageable: @vehicle)
  end

  scenario "Signed-in user uploads new document" do
    sign_in @admin
    visit edit_vehicle_image_path(@vehicle, @image)
    expect(page).to have_title('Bus 4x4 - Service Manager')
    expect(page).to have_selector('h1', text: "Edit document, #{@image.name}")
    expect( find(:css, "select#image_document_type_id").value).to eq(@image.document_type.id.to_s)
    expect( find(:css, "input#image_name").value).to eq(@image.name)
    expect( find(:css, "input#image_description").value).to eq(@image.description)
    expect(page).to have_xpath("//img[contains(@src, 'delivery_sheet.pdf')]")

    select "Modification Certificate", from: "image_document_type_id"
    fill_in 'image_name', with: 'Changed Inspection Sheet'
    fill_in 'image_description', with: 'Description of changed Inspection Sheet'
    click_button 'Update Document'

    expect(page).to have_selector('h3', text: "Documents")
    expect(page).to have_content("The document has been updated.")
    expect(page).to have_content("Changed Inspection Sheet")
    expect(page).to have_content("Description of changed Inspection Sheet")
  end
end

