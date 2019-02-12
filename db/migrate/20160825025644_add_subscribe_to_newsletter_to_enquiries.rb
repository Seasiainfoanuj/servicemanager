class AddSubscribeToNewsletterToEnquiries < ActiveRecord::Migration
  def change
    add_column :enquiries, :subscribe_to_newsletter, :boolean, default: false
  end
end
