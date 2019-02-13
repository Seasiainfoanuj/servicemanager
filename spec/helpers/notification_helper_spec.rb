# require 'spec_helper'

# describe NotificationsHelper do
#   describe "#notification_document_path" do
#     before do
#       admin = create(:user, :admin)
#       @vehicle = create(:vehicle)
#       document_type = create(:document_type, name: 'Rego Certificate')
#       @image1 = create(:document, imageable: @vehicle, document_type: document_type)
#       @image2 = create(:document, imageable: @vehicle, document_type: document_type)
#       @notification_type = create(:notification_type, resource_name: 'Vehicle',
#               event_name: 'Rego Certificate', upload_required: true,
#               resource_document_type: 'Rego Certificate')
#       @notification = create(:notification, notification_type: @notification_type,
#               notifiable: @vehicle, completed_date: Date.today - 3.days)
#       @image1.update(created_at: Date.today - 1.month)
#       @image2.update(created_at: Date.today - 1.week)
#     end

#     it "returns the appropriate path when the document exists" do
#       expect(notification_document_path(@notification)).to eq("/vehicles/#{@vehicle.id.to_s}/images/#{@image2.id.to_s}/edit")
#     end

#     it "returns nil when the document does not exist" do
#       @notification_type.update(resource_document_type: 'Rego 2 Certificate')
#       expect(notification_document_path(@notification)).to eq(nil)
#     end
#   end
# end