class CreateQuoteCoverLetters < ActiveRecord::Migration
  def change
    create_table :quote_cover_letters do |t|
      t.belongs_to :quote, index: true
      t.string :title
      t.text :text

      t.timestamps
    end
  end
end
