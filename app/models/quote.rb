class Quote < ActiveRecord::Base

  include PublicActivity::Common

  acts_as_taggable

  belongs_to :invoice_company
  belongs_to :customer, :class_name => "User"
  belongs_to :manager, :class_name => "User"
  belongs_to :master_quote
  has_many :items, :dependent => :destroy, :class_name => "QuoteItem"
  has_many :messages
  has_many :attachments, :class_name => "QuoteUpload"
  has_many :notes, as: :resource, :dependent => :destroy
  has_one :specification_sheet, :class_name => "QuoteSpecificationSheet", :dependent => :destroy
  has_one :build
  has_one :hire_agreement
  has_one :title_page, :class_name => "QuoteTitlePage", :dependent => :destroy
  has_one :cover_letter, :class_name => "QuoteCoverLetter", :dependent => :destroy
  has_one :summary_page, :class_name => "QuoteSummaryPage", :dependent => :destroy
  has_one :vehicle_contract, :dependent => :destroy

  has_one :sales_order
  has_many :enquiry_quotes
  has_many :enquiry, :through => :enquiry_quotes

  has_attached_file :po_upload, :styles => {
        :medium => "200x200>",
        :thumb => "100x100>",
        :pdf_thumbnail => ["", :jpg]
      }

  accepts_nested_attributes_for :items, allow_destroy: true
      # reject_if: proc { |att| att['name'].blank? || att['description'].blank? }

  STATUSES = ['draft', 'updated', 'changes requested', 'sent', 'resent', 
                           'viewed', 'accepted', 'cancelled', 'rejected']
  validates :invoice_company_id, presence: true
  validates :customer_id, presence: true
  validates :manager_id, presence: true
  validates :date, presence: true
  validates :number, uniqueness: true, presence: true
  validates :status, inclusion: { in: STATUSES }

  validates_attachment_size :po_upload, :less_than => 10.megabytes
  validates_attachment_content_type :po_upload, :content_type => ['image/jpeg', 'image/png', 'image/gif', 'application/pdf', 'application/msword', 'text/plain', 'text/xml']

  attr_accessor :delete_po_upload
  before_validation { po_upload.clear if delete_po_upload == '1' }

  before_save :mark_items_for_removal
  before_save :get_items
  before_save :calculate_total

  scope :recent_months, -> { Quote.where("quotes.updated_at > ?", Date.today - DEFAULT_QUOTE_HISTORY_MONTHS.months) }

  self.per_page = 10

  def subtotal_by_type(quote_item_type_name)
    return 0 unless items.any?
    item_type = QuoteItemType.find_by(name: quote_item_type_name)
    return 0 unless item_type
    total = 0
    items.each do |item|
      if item.quote_item_type_id == item_type.id
        total += item.line_total.cents
      end
    end
    total
  end

  def subtotals_per_quote_item_type
    item_types = {}
    QuoteItemType.all.each do |type|
      item_types[type.id] = type.name
    end

    subtotals = {}
    items.each do |item|
      if item.hide_cost
        name = 'Package'
      else
        name = item_types[item.quote_item_type_id]
      end
      if subtotals[name]
        subtotals[name] += item.line_total
      else
        subtotals[name] = item.line_total
      end
    end
    subtotals
  end

  def ref_name
    if customer.present?
     "#{number} - #{customer.name}"
    end
  end

  def resource_name
    "Quote #{number}"
  end

  def resource_link
    desc = "Quote #{number}: "
    link = "<a href=#{UrlHelper.quote_url(self)}>#{UrlHelper.quote_url(self)}</a><br>".html_safe
    desc + link
  end

  def to_param
    number.parameterize
  end

  def update_permitted?
    QuoteStatus.statuses_before_acceptance.include?(self.status)
  end

  def customer_item_list
    # returns the quote_items for this quote, seperating the items with hidden 
    # cost and limiting the quote item properties for the customer's view
    quote_items = items.includes(:quote_item_type)
    visible_to_customer = quote_items.select { |item| item.hide_cost == false }
    hidden_from_customer = quote_items.select { |item| item.hide_cost == true }
    list1 = []
    list2 = []
    if visible_to_customer.any?
      list1 << visible_to_customer.collect { |item| { quote_item_type: item.quote_item_type.name, item_name: item.name, description: item.description, unit_cost: item.cost_cents, quantity: item.quantity, hidden: item.hide_cost} }
    end
    if hidden_from_customer.any?
      list2 << hidden_from_customer.collect { |item| { quote_item_type: item.quote_item_type.name, item_name: item.name, description: item.description, unit_cost: item.cost_cents, quantity: item.quantity, hidden: item.hide_cost} } 
    end
    { visible_items: list1.first, hidden_items: list2.first }
  end

  def item_type_names
    item_types = []
    items.each do |item|
      quote_item_type = QuoteItemType.find_by(id: item.quote_item_type_id)
      next unless quote_item_type
      item_types << quote_item_type
    end  
    item_types.sort! { |a,b| a.sort_order <=> b.sort_order } 

    names = []
    item_types.each do |item|
      names << item.name.downcase.gsub(/-/,'_').gsub(/\W/,'_')
    end
    names.uniq
  end

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
        if item.tax_id.present?
          tax_rate = item.tax.rate
          tax_amount = item.cost*item.quantity*tax_rate
        else
          tax_amount = Money.new(0)
        end
        tax_totals << tax_amount
      end
      tax_totals.inject(:+)
    end
  end

  def grand_total
    if items.present?
      subtotal + tax_total
    else
      0
    end
  end

  def date_field
    date.strftime("%d/%m/%Y") if date.present?
  end

  def date_field=(date)
    self.date = Date.parse(date).strftime("%Y-%m-%d") if date.present?
  end

  def all_items_hidden?
    items.where(hide_cost: true).count == items.count
  end

  def copy_attachments_from_master(master_quote)
    master_quote.attachments.each do |file|
      attachment = QuoteUpload.new(
        quote: self,
        upload: file.upload
      )
      attachment.save if attachment.valid?
    end
  end

  def copy_specification_sheet_from_master(master_quote)
    return unless master_quote.specification_sheet

    specification_sheet =
      build_specification_sheet(
        upload: master_quote.specification_sheet.upload
      )
    specification_sheet.save if specification_sheet.valid?
  end

  def create_duplicate
    new_number = Quote.where.not(amendment: true).last.number.next
    Quote.create!(
      customer_id: customer_id,
      manager_id: manager_id,
      number: new_number,
      date: Time.now.strftime("%d/%m/%Y"),
      # discount: discount,
      status: 'draft',
      terms: terms,
      comments: comments,
      invoice_company_id: invoice_company_id,
      amendment: false
      )
  end

  private

    def mark_items_for_removal
      items.each do |item|
        if item.name.blank? && item.description.blank?
          item.mark_for_destruction
        end
      end
    end

    def get_items
       
      items_to_keep = self.items.reject { |item| item.marked_for_destruction? || item.name.blank? || item.description.blank? || item.quote_item_type_id.to_i == 0 || item.quantity.to_i == 0}
      self.items = items_to_keep.collect do |item|
        QuoteItem.find_or_create_by(name: item.name, description: item.description, quote_id: item.quote_id, cost_cents: item.cost_cents, quantity: item.quantity, tax_id: item.tax_id, 
        							hide_cost: item.hide_cost, quote_item_type_id: item.quote_item_type_id, position: item.position) do |i|
          i.cost = item.cost
          i.quantity = item.quantity
          i.tax_id = item.tax_id
          i.position = item.position
          i.hide_cost = item.hide_cost
          i.supplier_id = item.supplier_id
          i.service_provider_id = item.service_provider_id
          i.buy_price = item.buy_price
          i.buy_price_tax_id = item.buy_price_tax_id
          i.quote_item_type_id = item.quote_item_type_id
          i.primary_order = item.primary_order
        end
      end
    end

    def calculate_total
      return unless items.any?
      line_totals = []
      tax_totals = []

      items.each do |item|
        if item.quantity.present?
          line_total = item.cost_cents*item.quantity
          line_totals << line_total
        end

        if item.tax_id.present?
          tax_rate = item.tax.rate
          tax_amount = item.cost_cents*item.quantity*tax_rate.to_f
        else
          tax_amount = 0
        end

        tax_totals << tax_amount
      end

      line_totals = line_totals.sum
      tax_totals = tax_totals.sum

      self.total_cents = line_totals.to_i + tax_totals.to_i
    end
end
