module QuoteItemTypesHelper

  def options_for_taxable_item
    QuoteItemType::TAXABLE_OPTIONS.each_with_index.collect { |tax, inx| [tax, inx + 1] }
  end

  def options_for_quote_item_types
    QuoteItemType.all.collect { |type| [type.name, type.id] }
  end

end