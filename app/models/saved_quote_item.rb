class SavedQuoteItem < ActiveRecord::Base

  belongs_to :tax

  monetize :cost_cents

end
