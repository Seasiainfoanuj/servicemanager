class Stock < ActiveRecord::Base

  belongs_to :model, :class_name => "VehicleModel", :foreign_key => 'vehicle_model_id'
  belongs_to :supplier, :class_name => "User"
  has_many :notes, as: :resource, :dependent => :destroy
  has_one :stock_request

  validates :vehicle_model_id, presence: true
  validates :supplier_id, presence: true
  validates :stock_number, presence: true

  validates :vin_number, uniqueness: true, length: {is: 17}, allow_blank: true

  def resource_name
    "Stock Item #{stock_number.to_s}"
  end

  def resource_link
    desc = "Stock #{stock_number.to_s} - #{name}"
    link = "<br><a href=#{UrlHelper.stock_url(self)}>#{UrlHelper.stock_url(self)}</a><br>".html_safe
    desc + link
  end

  def make
    make = VehicleModel.find(vehicle_model_id).make if vehicle_model_id.present?
  end

  def name
    if vehicle_model_id
      model = VehicleModel.find(vehicle_model_id)
      make = model.make
      "#{make.name} #{model.name}"
    else
      "Stock Item"
    end
  end

  def number
    "#{stock_number}" if stock_number.present?
  end

  def eta_date_field
    eta.strftime("%d/%m/%Y") if eta.present?
  end

  def eta_date_field=(date)
    self.eta = DateTime.parse(date).strftime("%Y-%m-%d") if date.present?
  end

end
