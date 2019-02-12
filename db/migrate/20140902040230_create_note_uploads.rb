class CreateNoteUploads < ActiveRecord::Migration
  def change
    create_table :note_uploads do |t|
      t.references :note, index: true
      t.attachment :upload

      t.timestamps
    end
  end
end
