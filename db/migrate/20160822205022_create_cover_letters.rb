class CreateCoverLetters < ActiveRecord::Migration
  def change
    create_table :cover_letters do |t|
      t.references :covering_subject, polymorphic: true
      t.string :title
      t.text :content

      t.timestamps null: false
    end
  end
end
