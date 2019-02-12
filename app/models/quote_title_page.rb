class QuoteTitlePage < ActiveRecord::Base
  belongs_to :quote

  validates :quote_id, presence: true
  validates :title, presence: true
  validates :image_1, presence: true
  validates :image_2, presence: true

  has_attached_file :image_1,
    :styles => {
      :title_page => "680x425#",
      :thumb => "200x200>"
    }

  has_attached_file :image_2,
    :styles => {
      :title_page => "680x425#",
      :thumb => "200x200>"
    }

  validates_attachment_size :image_1, :less_than => 5.megabytes
  validates_attachment_content_type :image_1, :content_type => ['image/jpeg', 'image/png', 'image/gif']
  validates_attachment_size :image_2, :less_than => 5.megabytes
  validates_attachment_content_type :image_2, :content_type => ['image/jpeg', 'image/png', 'image/gif']
end
