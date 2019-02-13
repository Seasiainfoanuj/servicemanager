require "spec_helper"

feature "New Image page" do

  before(:each) do
    @admin = create(:user, :admin)
    @supplier = create(:user, :supplier)
    create(:document_type, name: 'Modification Certificate')
    create(:document_type, name: 'Pre Delivery Inspection Sheet')
    @vehicle = create(:vehicle, vehicle_number: "VEHICLE-1", supplier: @supplier)
  end

  scenario "Signed-in user uploads new document" do
    sign_in @admin
    visit vehicle_images_path(@vehicle)
    expect(page).to have_title('Bus 4x4 - Service Manager')
    expect(page).to have_selector('h3', text: "Documents")
    expect(page).to have_selector('h3', text: "Photos")
    click_link 'New document'
    expect(page).to have_title('Bus 4x4 - Service Manager')
    expect(page).to have_selector('h1', text: "New Document")
    expect(page).to have_selector('h3', text: "Document")
    expect(page).to have_content('Document type')
    expect(page).to have_content('Image name')
    expect(page).to have_content('Description')
    expect(page).to have_content('Attachment')

    select "Pre Delivery Inspection Sheet", from: "image_document_type_id"
    fill_in 'image_name', with: 'New Inspection Sheet'
    fill_in 'image_description', with: 'Description of new Inspection Sheet'
    attach_file 'image_image', fixture_image_path
    click_button 'Create Document'
    expect(page).to have_selector('h3', text: "Documents")
    expect(page).to have_content("A document has been created.")
    expect(page).to have_xpath("//img[contains(@src, 'thumb/delivery_sheet.pdf')]")
  end

  def fixture_image_path
    Rails.root.join('spec', 'fixtures', 'images', 'delivery_sheet.pdf')
  end

end