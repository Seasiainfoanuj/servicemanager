class QuoteSummaryPage < ActiveRecord::Base
  belongs_to :quote

  validates :quote_id, :text, presence: true
end
