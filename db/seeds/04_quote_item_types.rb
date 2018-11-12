QuoteItemType.delete_all

QuoteItemType.create(name: 'Vehicle', sort_order: 1, allow_many_per_quote: false)
QuoteItemType.create(name: 'Chassis', sort_order: 1, allow_many_per_quote: false)
QuoteItemType.create(name: 'Body', sort_order: 2, allow_many_per_quote: false)
QuoteItemType.create(name: 'Engine', sort_order: 3, allow_many_per_quote: false)

QuoteItemType.create(name: 'Kit', sort_order: 4, allow_many_per_quote: true)
QuoteItemType.create(name: 'Accessory', sort_order: 5, allow_many_per_quote: true)
QuoteItemType.create(name: 'Vehicle Registration', sort_order: 10, allow_many_per_quote: false)
QuoteItemType.create(name: 'Stamp duty', sort_order: 11, allow_many_per_quote: false)
QuoteItemType.create(name: 'CTP Insurance', sort_order: 12, allow_many_per_quote: false)
QuoteItemType.create(name: 'Other', sort_order: 99, allow_many_per_quote: true)

puts "#{QuoteItemType.count} QuoteItemTypes loaded"
