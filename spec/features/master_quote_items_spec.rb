require "spec_helper"

feature "Master quote item management" do
  let(:body) { create(:quote_item_type, name: 'body') }
  let(:engine) { create(:quote_item_type, name: 'engine') }
  let(:add_on) { create(:quote_item_type, name: 'add on') }

  background do
    @admin = create(:user, :admin)

    @item_1 = create(:master_quote_item, quote_item_type: body)
    @item_2 = create(:master_quote_item, quote_item_type: engine)
    @item_3 = create(:master_quote_item, quote_item_type: add_on)
  end

  scenario "viewing master quote items", :js => true do
    sign_in @admin
    visit master_quote_items_path

    expect(page).to have_content @item_1.name
    expect(page).to have_content @item_2.name
    expect(page).to have_content @item_3.name
  end

end
