class AddMasterQuoteToQuote < ActiveRecord::Migration
  def change
    add_reference :quotes, :master_quote, index: true
  end
end
