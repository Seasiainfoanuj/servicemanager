class QuoteCoverLetter < ActiveRecord::Base
  belongs_to :quote

  validates :quote_id, presence: true
  validates :title, presence: true
end
