class HireAgreement < ActiveRecord::Base

  include PublicActivity::Common

  belongs_to :type, :class_name => "HireAgreementType", :foreign_key => 'hire_agreement_type_id'
  belongs_to :vehicle
  belongs_to :customer, :class_name => "User"
  belongs_to :manager, :class_name => "User"
  belongs_to :quote
  belongs_to :invoice_company
  has_many :hire_uploads, :dependent => :destroy
  has_many :notes, as: :resource, :dependent => :destroy
  has_many :hire_charges, :dependent => :destroy
  has_one :on_hire_report
  has_one :off_hire_report

  accepts_nested_attributes_for :hire_charges, :reject_if => proc { |att| att['name'].blank? && att['quantity'].blank? }, :allow_destroy => true

  validates :hire_agreement_type_id, presence: true
  validates :invoice_company_id, presence: true
  validates :vehicle_id, presence: true
  validates :customer_id, presence: true
  validates :status, presence: true
  validates :pickup_time, presence: true
  validates :return_time, presence: true

  def to_param
    uid.parameterize
  end

  def resource_name
    "Hire Agreement #{uid.parameterize}"
  end

  def resource_link
    desc = "Hire Agreement with #{customer.company_name} for #{vehicle.resource_name}"
    link = "<a href=#{UrlHelper.hire_agreement_url(self)}>#{UrlHelper.hire_agreement_url(self)}</a><br>".html_safe
    "#{desc} #{link}"
  end   

  def pickup_datetime
    pickup_time.strftime("%Y-%m-%d %H:%M") if pickup_time.present?
  end

  def pickup_date_field
    pickup_time.strftime("%d/%m/%Y") if pickup_time.present?
  end

  def pickup_time_field
    pickup_time.strftime("%I:%M %p") if pickup_time.present?
  end

  def return_datetime
    return_time.strftime("%Y-%m-%d %H:%M") if return_time.present?
  end

  def return_date_field
    return_time.strftime("%d/%m/%Y") if return_time.present?
  end

  def return_time_field
    return_time.strftime("%I:%M %p") if return_time.present?
  end

  def date_range
    if pickup_time.present? && return_time.present?
      "#{pickup_time.strftime("%d/%m/%Y %l:%M %p")} - #{return_time.strftime("%d/%m/%Y %l:%M %p")}"
    end
  end

  def date_range=(val)
    if val.present?
      pickup_time, return_time = val.split(' - ')
      self.pickup_time = Time.zone.parse(pickup_time)
      self.return_time = Time.zone.parse(return_time)
    end
  end

  def demurrage_start_datetime
    demurrage_start_time.strftime("%Y-%m-%d %H:%M") if demurrage_start_time.present?
  end

  def demurrage_start_date_field
    demurrage_start_time.strftime("%d/%m/%Y") if demurrage_start_time.present?
  end

  def demurrage_start_time_field
    demurrage_start_time.strftime("%I:%M %p") if demurrage_start_time.present?
  end

  def demurrage_end_datetime
    demurrage_end_time.strftime("%Y-%m-%d %H:%M") if demurrage_end_time.present?
  end

  def demurrage_end_date_field
    demurrage_end_time.strftime("%d/%m/%Y") if demurrage_end_time.present?
  end

  def demurrage_end_time_field
    demurrage_end_time.strftime("%I:%M %p") if demurrage_end_time.present?
  end

  def demurrage_date_range
    if demurrage_start_time.present? && demurrage_end_time.present?
      "#{demurrage_start_time.strftime("%d/%m/%Y %l:%M %p")} - #{demurrage_end_time.strftime("%d/%m/%Y %l:%M %p")}"
    end
  end

  def demurrage_date_range=(val)
    if val.present?
      demurrage_start_time, demurrage_end_time = val.split(' - ')
      self.demurrage_start_time = Time.zone.parse(demurrage_start_time)
      self.demurrage_end_time = Time.zone.parse(demurrage_end_time)
    end
  end

  def number_of_days
    (return_time.to_date - pickup_time.to_date).to_i + 1
  end

  def demurrage_days
    (demurrage_end_time.to_date - demurrage_start_time.to_date).to_i + 1 if demurrage_end_time.present? && demurrage_start_time.present?
  end

  def km_allowance
    number_of_days * daily_km_allowance if daily_km_allowance.present?
  end

  def total_km
    if on_hire_report.present? && on_hire_report.odometer_reading.present? && off_hire_report.present? && off_hire_report.odometer_reading.present?
      off_hire_report.odometer_reading - on_hire_report.odometer_reading
    end
  end

  def rental_fee
    (number_of_days * daily_rate).to_f if daily_rate.present?
  end

  def demurrage_fee
    (demurrage_days * demurrage_rate).to_f if demurrage_rate.present? && demurrage_days.present?
  end

  def total_excess_km
    if total_km.present? && daily_km_allowance.present?
      total = total_km - (daily_km_allowance * number_of_days)
      if total > 0
        total
      else
        0
      end
    end
  end

  def excess_km_fee
    if total_excess_km.present? && excess_km_rate.present?
      total_excess_km * excess_km_rate.to_f
    end
  end

  def fuel_service_charge
    if off_hire_report && off_hire_report.fuel_litres.present? && fuel_service_fee.present?
      (off_hire_report.fuel_litres * fuel_service_fee).to_f
    end
  end

  def charges_subtotal
    if hire_charges.present?
      line_totals = []
      hire_charges.each do |hire_charge|
        hire_charge_cost = hire_charge.amount
        if hire_charge.quantity.present?
          line_total = hire_charge_cost * hire_charge.quantity
          line_totals << line_total
        end
      end
      line_totals.inject(:+)
    end
  end

  def charges_tax_total
    if hire_charges.present?
      tax_totals = []
      hire_charges.each do |hire_charge|
        if hire_charge.tax_id.present?
          tax_rate = hire_charge.tax.rate
          tax_amount = hire_charge.amount * hire_charge.quantity*tax_rate
        else
          tax_amount = Money.new(0)
        end
        tax_totals << tax_amount
      end
      tax_totals.inject(:+)
    end
  end

  def charges_grand_total
    if hire_charges.present?
      charges_subtotal + charges_tax_total
    end
  end

  def reminder_message(hire_agreement, action)
    if action == "pickup"
      "This is a reminder that your vehicle will be ready for pickup " +
      "on #{hire_agreement.pickup_datetime} at #{hire_agreement.pickup_location}."
    else  
      "This is a reminder that your vehicle is scheduled to be returned " +
      "on #{hire_agreement.return_datetime} at #{hire_agreement.return_location}. "
    end
  end

  def self.send_notifications(action)
    @hire_agreements.each do |hire_agreement|
      message = hire_agreement.reminder_message(hire_agreement, action)
      if hire_agreement.manager
        HireAgreementMailer.delay.pickup_return_notification(
          hire_agreement.manager.id, hire_agreement.id, message, action)
      end
      if hire_agreement.customer
        HireAgreementMailer.delay.pickup_return_notification(
          hire_agreement.customer.id, hire_agreement.id, message, action)
      end
      invoice_company_admin_id = hire_agreement.invoice_company.accounts_admin.id
      HireAgreementMailer.delay.pickup_return_notification(
        invoice_company_admin_id, hire_agreement.id, message, action)
    end
  end

  def self.send_reminders_for_tomorrow
    open_hire_agreements = HireAgreement.where("status IN ('confirmed', 'awaiting confirmation', 'on hire') AND return_time > ?", Date.today.strftime("%Y-%m-%d"))
    @hire_agreements = open_hire_agreements.where("DATE(pickup_time) = ?", 1.day.from_now.strftime("%Y-%m-%d"))
    HireAgreement.send_notifications('pickup') unless @hire_agreements.empty?
    @hire_agreements = open_hire_agreements.where("DATE(return_time) = ?", 1.day.from_now.strftime("%Y-%m-%d"))
    HireAgreement.send_notifications('pickup') unless @hire_agreements.empty?
  end

  def self.send_reminders_for_next_week
    open_hire_agreements = HireAgreement.where("status IN ('confirmed', 'awaiting confirmation', 'on hire') AND return_time > ?", Date.today.strftime("%Y-%m-%d"))
    @hire_agreements = open_hire_agreements.where("DATE(pickup_time) = ?", 1.week.from_now.strftime("%Y-%m-%d"))
    HireAgreement.send_notifications('return') unless @hire_agreements.empty?
    @hire_agreements = open_hire_agreements.where("DATE(return_time) = ?", 1.week.from_now.strftime("%Y-%m-%d"))
    HireAgreement.send_notifications('return') unless @hire_agreements.empty?
  end

end
