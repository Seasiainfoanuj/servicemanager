class Tax < ActiveRecord::Base
  default_scope { order('position ASC') }

  has_many :quote_items
  has_many :saved_quote_items  
  has_many :hire_charges

  validates :position, numericality: { only_integer: true, allow_nil: true }
  validates :name, uniqueness: true

  def rate_percent
    rate*100 if rate
  end

  def rate_percent=(percent)
    self.rate = percent.to_d/100
  end

end
