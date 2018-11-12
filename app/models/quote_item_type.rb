class QuoteItemType < ActiveRecord::Base

  default_scope { order("sort_order ASC") }

  TAXABLE_OPTIONS = ['Always taxed', 'Not taxed', 'May be taxed']
  ALWAYS_TAXED = 1
  NOT_TAXED = 2
  MAY_BE_TAXED = 3

  validates :taxable, presence: true,
                    inclusion: { in: 1..3 }

  validates :name, presence: true, 
                   uniqueness: true,
                   length: { minimum: 2, maximum: 30 }

end

