# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

####### Test Data #######

user_seeds = File.join(Rails.root, 'db', 'seeds', '01_users.rb')
vehicle_seeds = File.join(Rails.root, 'db', 'seeds', '02_vehicles.rb')
workorder_seeds = File.join(Rails.root, 'db', 'seeds', '03_workorders.rb')
quote_item_type_seeds = File.join(Rails.root, 'db', 'seeds', '04_quote_item_types.rb')

if Rails.env == 'development'
  # load user_seeds
  # load vehicle_seeds
  # load workorder_seeds
  load quote_item_type_seeds
  puts "Development seed data loaded"
end

if Rails.env == 'production'
  load quote_item_type_seeds
  puts "Production seed data loaded"
end  