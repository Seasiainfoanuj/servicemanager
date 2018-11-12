class MasterQuote < ActiveRecord::Base

  include PublicActivity::Common

  belongs_to :type, :class_name => "MasterQuoteType", :foreign_key => "master_quote_type_id"
  has_one :title_page, :class_name => "MasterQuoteTitlePage", :dependent => :destroy
  has_one :summary_page, :class_name => "MasterQuoteSummaryPage", :dependent => :destroy
  has_and_belongs_to_many :items, :class_name => "MasterQuoteItem", foreign_key: "quote_id", :association_foreign_key => "item_id"
            # , -> { order("item_type, position") },
  has_many :attachments, :class_name => "MasterQuoteUpload"
  has_one :specification_sheet, :class_name => "MasterQuoteSpecificationSheet", :dependent => :destroy
  validates :master_quote_type_id, presence: true
  validates :name, presence: true
  validates :seating_number, numericality: { only_integer: true, allow_nil: true }

  accepts_nested_attributes_for :items, :reject_if => proc { |att| att['name'].blank? && att['description'].blank? }, :allow_destroy => true

  #before_save :get_items

  def subtotal
    if items.present?
      line_totals = []
      items.each do |item|
        item_cost = item.cost
        if item.quantity.present?
          line_total = item_cost*item.quantity
          line_totals << line_total
        end
      end
      line_totals.inject(:+)
    end
  end

  def tax_total
    if items.present?
      tax_totals = []
      items.each do |item|
        if item.cost_tax_id.present?
          tax_rate = item.cost_tax.rate
          tax_amount = item.cost*item.quantity*tax_rate
        else
          tax_amount = 0
        end
        tax_totals << tax_amount
      end
      tax_totals.inject(:+)
    end
  end

  def grand_total
    if items.present? && subtotal.present? && tax_total.present?
      subtotal + tax_total
    end
  end

  private

    def get_items
      self.items = self.items.collect do |item|
        MasterQuoteItem.find_or_create_by(name: item.name) do |i|
          i.quote_item_type_id = item.quote_item_type_id
          i.description = item.description
          i.cost_cents = item.cost_cents
          i.quantity = item.quantity
          i.cost_tax_id = item.cost_tax_id
        end
      end
    end
end
