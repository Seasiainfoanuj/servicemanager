class Address < ActiveRecord::Base

  belongs_to :user
  belongs_to :enquiry
  belongs_to :addressable, polymorphic: true

  before_validation(on: :create) do
    correct_format_country
    correct_format_state if ['Australia', ''].include? country
    self.postcode = postcode.strip
    self.suburb = suburb.strip.titleize
  end

  POSTAL = 0
  PHYSICAL = 1
  BILLING = 2
  DELIVERY = 3

  AUSTRALIAN_STATES = %w(ACT NSW NT QLD SA TAS VIC WA)

  validates_presence_of :line_1, :suburb
  validates :address_type, presence: true,
                           inclusion: { in: [0,1,2,3] }
  validates :state, presence: true,
                    inclusion: { in: AUSTRALIAN_STATES },
                    if: ->{ ['Australia', ''].include? country }
  validates :postcode, numericality: { only_integer: true },
                       length: { is: 4 },
                       if: ->{ ['Australia', ''].include? country }

  scope :postal, -> { Address.where(address_type: POSTAL) }
  scope :physical, -> { Address.where(address_type: PHYSICAL) }
  scope :billing, -> { Address.where(address_type: BILLING) }
  scope :delivery, -> { Address.where(address_type: DELIVERY) }

  def self.address_types
    ['Postal', 'Physical', 'Billing', 'Delivery']
  end

  def postal?
    address_type == POSTAL
  end

  def physical?
    address_type == PHYSICAL
  end

  def billing?
    address_type == BILLING
  end

  def delivery?
    address_type == DELIVERY
  end

  def address_type_short
    Address.address_types[address_type].downcase
  end

  def address_type_display
    "#{Address.address_types[address_type]} Address"
  end

  def line_2_display
    line_2 || ""
  end

  def state_display
    state || ""
  end

  def postcode_display
    postcode || ""
  end

  def country_display
    country || "Australia"
  end

  def to_s
    addr = [line_1]
    addr << line_2 if line_2.present?
    addr << suburb
    addr << state if state.present?
    addr << postcode if postcode.present?
    addr << country_display
    addr.join(', ')
  end

  private

    def correct_format_country
      if country.present? 
        if ['au', 'aust', 'aust.', 'australia'].include? country.downcase.strip
          self.country = 'Australia'
        end
      else
        self.country = 'Australia'
      end
    end

    def correct_format_state
      case state.downcase.strip
      when 'qld', 'queensland'
        self.state = 'QLD'
      when 'act'
        self.state = 'ACT'
      when 'nt', 'northern territory'
        self.state = 'NT'
      when 'sa', 'south australia'
        self.state = 'SA'
      when 'vic', 'victoria'
        self.state = 'VIC'
      when 'tas', 'tasmania'
        self.state = 'TAS'
      when 'wa', 'western australia'
        self.state = 'WA'
      when 'nsw', 'new south wales'
        self.state = 'NSW'
      end
    end
end
