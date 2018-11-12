namespace :create_quote_item_types do

  desc "Create initial Quote Item Type records"
  task "add_quote_item_type_records" => :environment do

    puts "#{QuoteItemType.count} Quote Item Types are already in database."
    always_taxed = QuoteItemType::ALWAYS_TAXED
    not_taxed = QuoteItemType::NOT_TAXED
    may_be_taxed = QuoteItemType::MAY_BE_TAXED

    unless QuoteItemType.any?
      QuoteItemType.create(name: 'Vehicle', sort_order: 1, allow_many_per_quote: false, taxable: always_taxed)
      QuoteItemType.create(name: 'Chassis', sort_order: 1, allow_many_per_quote: false, taxable: always_taxed)
      QuoteItemType.create(name: 'Body', sort_order: 2, allow_many_per_quote: false, taxable: always_taxed)
      QuoteItemType.create(name: 'Engine', sort_order: 3, allow_many_per_quote: false, taxable: always_taxed)
      QuoteItemType.create(name: 'Kit', sort_order: 4, allow_many_per_quote: true, taxable: always_taxed)
      QuoteItemType.create(name: 'Accessory', sort_order: 5, allow_many_per_quote: true, taxable: always_taxed)
      QuoteItemType.create(name: 'Vehicle Registration', sort_order: 10, allow_many_per_quote: false, taxable: not_taxed)
      QuoteItemType.create(name: 'Stamp duty', sort_order: 11, allow_many_per_quote: false, taxable: not_taxed)
      QuoteItemType.create(name: 'CTP Insurance', sort_order: 12, allow_many_per_quote: false, taxable: not_taxed)
      QuoteItemType.create(name: 'Other', sort_order: 99, allow_many_per_quote: true, taxable: may_be_taxed)
    end  

    puts "Quote Item Types now in database: #{QuoteItemType.count}"

  end
end
    