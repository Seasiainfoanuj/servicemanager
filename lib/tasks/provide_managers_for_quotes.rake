namespace :quotes do

  desc "Provide managers for quotes that have no manager"
  task "assign_quote_manager" => :environment do
    quotes = Quote.where(manager_id: nil)
    puts "#{quotes.count} quotes were found without a manager"
    quotes_count = 0
    steve = User.find_by(first_name: 'Steve', last_name: 'Hargreaves')
    quotes.each do |quote|
      quote.manager = steve
      quote.save!
      quotes_count += 1
    end
    puts "#{quotes_count} quotes have been modified."
    quotes = Quote.where(manager_id: nil)
    puts "#{quotes.count} quotes were found without a manager"
  end
end