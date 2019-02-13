class CreateDocumentType < ActiveRecord::Migration
  def change
    create_table :document_types do |t|
      t.string :name
      t.string :label_color
      t.timestamps null: false
    end
  end
end
