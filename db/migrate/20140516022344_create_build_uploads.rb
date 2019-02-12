class CreateBuildUploads < ActiveRecord::Migration
  def change
    create_table :build_uploads do |t|
      t.belongs_to :build, index: true
      t.attachment :upload

      t.timestamps
    end
  end
end
