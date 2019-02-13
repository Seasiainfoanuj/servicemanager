namespace :vehicle_models do

  desc "Point Vehicle to correct Model"
  task "correct_vehicle_model_links" => :environment do
    all_models = VehicleModel.all.sort_by { |model| [model.vehicle_make_id, model.name, model.year] }

    Vehicle.includes(model: :make).each do |vehicle|
      begin
        vehicle.model_year = vehicle.model.year
        selected_model = all_models.select { |model| model.vehicle_make_id == vehicle.make.id && model.name == vehicle.model.name }.first
        vehicle.vehicle_model_id = selected_model.id

        case vehicle.status
        when 'available', 'on_offer'
          vehicle.usage_status = 'for sale'
        when 'sold'
          vehicle.usage_status = 'sold'
        else
          vehicle.status = 'available'
        end

        if vehicle.transmission == ""
          vehicle.transmission = "Unknown"
        end

        if vehicle.vin_number != "" && vehicle.vin_number.length != 17
          filler = "?" * (17 - vehicle.vin_number.length)
          vehicle.vin_number += filler
        end

        vehicle.save!
        puts "Vehicle description: #{vehicle.make.name} #{vehicle.model.name} #{vehicle.model_year}"
      rescue
        puts "Error in vehicle #{vehicle.id}"
      end
    end

    puts "\nEND OF REPORT"
    puts "-----------------------------"
  end

  desc "Report on used Vehicle Models and delete unused models"
  task "vehicle_models_usage_report" => :environment do
    all_model_count = 0
    unused_models = []
    puts "\nReport on used Vehicle Models"
    puts "-----------------------------"

    VehicleModel.all.each do |model|
      has_stocks = model.stocks.any?
      has_vehicles = model.vehicles.any?
      puts "#{model.name} has stocks" if has_stocks
      puts "#{model.name} has vehicles" if has_vehicles
      unless has_stocks || has_vehicles
        unused_models << model
      end
    end

    puts "\nReport on unused Vehicle Models"
    puts "-------------------------------"
    unused_models.map { |model| puts "Unused: #{model.id} #{model.name} #{model.year}" }

    unused_models.each { |model| model.delete }
    puts "\nEND OF REPORT"
  end

  desc "Report on Vehicle Model integrity"
  task "validate_vehicle_model" => :environment do
    puts "\nValidation Report Vehicle Models"
    puts "--------------------------------"

    VehicleModel.all.each do |model|
      if model.valid?
        print '.'
      else
        puts "\n#{model.id} - #{model.errors.messages}"
      end
    end
    puts "\nEND OF REPORT"
  end
end
