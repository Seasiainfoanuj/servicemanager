class MasterQuoteType < ActiveRecord::Base
  has_many :master_quotes
  validates :name, presence: true
end
