class AddPoUploadToQuote < ActiveRecord::Migration
  def change
    add_attachment :quotes, :po_upload
  end
end
