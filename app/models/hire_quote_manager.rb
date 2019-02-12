# The HireQuoteManager class is responsible to coordinate events within the
# preparation of a Hire Quote. It is an attempt to keep related controllers
# clean from process logic and notify objects within the Hire Quote process
# of client-side events that must be broadcasted to other objects.
class HireQuoteManager
  
  def self.create_amendment(cancelled_quote)
    new_version = HireQuote.get_new_version(cancelled_quote.uid)
    new_reference = "#{cancelled_quote.uid}-#{new_version}"
    new_quote = cancelled_quote.dup
    new_quote
    new_quote.version = new_version
    new_quote.reference = new_reference
    new_quote.status = 'draft'
    new_quote.status_date = Date.today
    new_quote.last_viewed = Date.today
    new_quote.save!
    copy_hire_vehicles(cancelled_quote, new_quote)
    new_quote
  end

  private 

    def self.copy_hire_vehicles(from_quote, to_quote)
      from_quote.vehicles.each do |vehicle|
        new_vehicle = vehicle.dup
        new_vehicle.hire_quote_id = to_quote.id
        new_vehicle.save!
        copy_vehicle_fees(vehicle, new_vehicle)
        copy_vehicle_addons(vehicle, new_vehicle)
      end
    end

    def self.copy_vehicle_fees(from_vehicle, to_vehicle)
      from_vehicle.fees.each { |fee| to_vehicle.fees << fee }
      to_vehicle.save!
    end

    def self.copy_vehicle_addons(from_vehicle, to_vehicle)
      from_vehicle.addons.each { |addon| to_vehicle.addons << addon }
      to_vehicle.save!
    end

end