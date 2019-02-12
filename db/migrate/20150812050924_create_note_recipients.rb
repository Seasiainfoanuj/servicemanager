class CreateNoteRecipients < ActiveRecord::Migration
  def change
    create_table :note_recipients do |t|
      t.references :note
      t.references :user
    end
  end
end

