module QuoteItemTypes
  extend ActiveSupport::Concern
  include ItemTypeConstants
  included do

    def self.options_for_item_type
      options = []
      QuoteItem::ITEM_TYPES.each_with_index.map { |type, inx| options << [type, inx] }
      options
    end

    def item_type_display
      return "" if item_type.nil?
      ITEM_TYPES[item_type]
    end
    
  end
end