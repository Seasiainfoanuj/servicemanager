class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.references :resource, index: true, polymorphic: true
      t.references :author, index: true
      t.boolean :public
      t.text :comments
      t.timestamps
    end
  end
end
