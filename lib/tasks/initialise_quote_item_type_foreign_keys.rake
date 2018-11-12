namespace :quote_item_types do

  desc "Assign initial quote item type values to master quote items"
  task "initialise_master_quote_items" => :environment do
    other_quote_item_type = QuoteItemType.find_by(name: 'Other')
    master_quote_item_total = MasterQuoteItem.count
    master_quote_items_updated = 0

    if other_quote_item_type
      MasterQuoteItem.all.each do |master_quote_item|
        unless master_quote_item.quote_item_type_id
          master_quote_item.quote_item_type_id = other_quote_item_type.id
          master_quote_item.primary_order = 99
          master_quote_item.save!
          master_quote_items_updated += 1
        end
      end
    end    

    puts "Master Quote Items in database: #{master_quote_item_total}"
    puts "Total Master Quote Items updated: #{master_quote_items_updated}"
  end

  desc "Assign initial quote item type values to quote items"
  task "initialise_quote_items" => :environment do
    other_quote_item_type = QuoteItemType.find_by(name: 'Other')
    quote_item_total = QuoteItem.count
    quote_items_updated = 0

    if other_quote_item_type
      QuoteItem.all.each do |quote_item|
        unless quote_item.quote_item_type_id
          quote_item.quote_item_type_id = other_quote_item_type.id
          quote_item.primary_order = 99
          quote_item.save!
          quote_items_updated += 1
        end
      end
    end    

    puts "Quote Items in database: #{quote_item_total}"
    puts "Total Quote Items updated: #{quote_items_updated}"
  end
end