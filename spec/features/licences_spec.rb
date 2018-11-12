require "spec_helper"

feature "Licence" do
  scenario "User can add/edit licence details when editing profile" do
    user = create(:user, :admin)
    
    sign_in user
    visit edit_user_path(user)

    within("#licence-details-form") do
      fill_in 'user_licence_attributes_number', :with => "LICENCE-99"
      fill_in 'user_licence_attributes_state_of_issue', :with => "QLD"
      fill_in 'user_licence_attributes_expiry_date_field', :with => "30/12/2014"
      click_on 'Update'
    end
  end
end