class MasterQuoteSummaryPage < ActiveRecord::Base
  belongs_to :master_quote

  validates :master_quote_id, :text, presence: true
end
