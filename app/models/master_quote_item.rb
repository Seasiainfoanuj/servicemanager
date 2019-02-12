class MasterQuoteItem < ActiveRecord::Base

  has_and_belongs_to_many :master_quotes, foreign_key: "quote_id", :association_foreign_key => "item_id"
  belongs_to :supplier, :class_name => "User"
  belongs_to :service_provider, :class_name => "User"
  belongs_to :quote_item_type

  belongs_to :cost_tax, :class_name => "Tax"
  belongs_to :buy_price_tax, :class_name => "Tax"

  validates :cost_cents, presence: true

  acts_as_taggable

  monetize :cost_cents
  monetize :buy_price_cents

  default_scope { order('primary_order, position') }

  # scope :recent_months, -> { Quote.where("quotes.updated_at > ?", Date.today - DEFAULT_QUOTE_HISTORY_MONTHS.months) }

  def cost_float
    cost.to_f
  end

  def item_type_name(plural = false)
    return "" unless quote_item_type
    plural && quote_item_type.allow_many_per_quote ? quote_item_type.name.pluralize : quote_item_type.name
  end

  def line_total
    if cost && quantity
      cost*quantity
    else
      cost
    end
  end

  def line_total_float
    line_total.to_f
  end

  def tax_total
    if cost_tax_id
      tax = Tax.find(cost_tax_id)
      if cost && quantity
        cost*quantity*tax.rate
      elsif cost
        cost*tax.rate
      else
        Money.new(0)
      end
    end
  end
end
