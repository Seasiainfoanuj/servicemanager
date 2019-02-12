MasterQuote.delete_all

master_quote_type = MasterQuoteType.create(name: 'People Mover')

master_quote = MasterQuote.create(type: master_quote_type,
    vehicle_make: 'Mazda',
    vehicle_model: 'Premacy',
    transmission_type: '2WD',
    name: 'Mazda Premacy 1895',
    seating_number: 5,
    terms: Faker::Lorem.paragraphs,
    notes: Faker::Lorem.paragraphs)

MasterQuoteItem.create(
    name: Faker::Lorem.word,
    description: Faker::Lorem.paragraphs,
    cost_cents: Faker::Number.number(4),
    cost_currency: 'ZAR',
    cost_tax: { Tax.first || create(:tax, name: 'GST', rate: 1.12) },
    buy_price_cents: Faker::Number.number(4),
    buy_price_currency: 'EUR',
    buy_price_tax: { Tax.first },
    supplier: { factory: [:user, :supplier] },
    service_provider: { factory: [:user, :service_provider] },
    quantity: Faker::Number.number(2),

    after(:create) do |master_quote_item|
      master_quote_item.master_quotes << FactoryGirl.build(:master_quote)
    end
  end
