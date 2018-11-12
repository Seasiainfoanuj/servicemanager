class QuoteItem < ActiveRecord::Base

  belongs_to :quote
  belongs_to :master_quote_item
  belongs_to :supplier, :class_name => "User"
  belongs_to :service_provider, :class_name => "User"
  belongs_to :tax
  belongs_to :buy_price_tax, :class_name => "Tax"
  belongs_to :quote_item_type

  monetize :cost_cents
  monetize :buy_price_cents
  default_scope { order('primary_order, position') }

  # did not work with rspec :(
  # QuoteItemType.all.each do |item_type|
  #   scope item_type.name.downcase.gsub(/-/,'_').gsub(/\W/,'_').to_sym, -> { QuoteItem.where(quote_item_type_id: item_type.id) }
  # end

  scope :vehicle, -> { QuoteItem.joins(:quote_item_type).where(quote_item_types: { name: 'Vehicle' }) }
  scope :chassis, -> { QuoteItem.joins(:quote_item_type).where(quote_item_types: { name: 'Chassis' }) }
  scope :body, -> { QuoteItem.joins(:quote_item_type).where(quote_item_types: { name: 'Body' }) }
  scope :engine, -> { QuoteItem.joins(:quote_item_type).where(quote_item_types: { name: 'Vehicle' }) }
  scope :kit, -> { QuoteItem.joins(:quote_item_type).where(quote_item_types: { name: 'Kit' }) }
  scope :accessory, -> { QuoteItem.joins(:quote_item_type).where(quote_item_types: { name: 'Accessory' }) }
  scope :vehicle_registration, -> { QuoteItem.joins(:quote_item_type).where(quote_item_types: { name: 'Vehicle Registration' }) }
  scope :stamp_duty, -> { QuoteItem.joins(:quote_item_type).where(quote_item_types: { name: 'Stamp duty' }) }
  scope :ctp_insurance, -> { QuoteItem.joins(:quote_item_type).where(quote_item_types: { name: 'CTP insurance' }) }
  scope :other, -> { QuoteItem.joins(:quote_item_type).where(quote_item_types: { name: 'Other' }) }

  def item_type_name(plural = false)
    return "" unless quote_item_type
    plural && quote_item_type.allow_many_per_quote ? quote_item_type.name.pluralize : quote_item_type.name
  end

  def cost_float
    cost.to_f
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
    if tax_id
      tax = Tax.find(tax_id)
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
