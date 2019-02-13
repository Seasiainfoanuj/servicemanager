namespace :quote_statistics do

  desc "Find duplicate quotes"
  task "find_duplicate_quotes" => :environment do
    quote_duplicate_count = 0
    sql_str  = 'SELECT customer_id, manager_id, date from quotes '
    sql_str += 'GROUP BY customer_id, manager_id, date '
    sql_str += 'HAVING COUNT(*) > 1;'
    results = Quote.connection.select_all(sql_str)
    count = 0
    draft_quotes = []
    cancelled_quotes = []
    report = ""
    results.each do |dup|
      Rails.logger.info "\n"
      quotes = Quote.where(customer_id: dup['customer_id'], manager_id: dup['manager_id'], date: dup['date'])
      quote_1 = quotes[0]
      draft_quotes << quote_1.number if quote_1.status == 'draft'
      cancelled_quotes << quote_1.number if quote_1.status == 'cancelled'
      quote_1_latest_activity = PublicActivity::Activity.order("created_at desc").where(:trackable_type => "Quote", :trackable_id => quote_1.id).first
      orig_items = quote_1.items.collect { |item| [item.name, item.quantity, item.cost.amount.to_i]}
      orig_quote_number = quote_1.number
      (1..quotes.count-1).each do |index|
        quote = quotes[index]
        draft_quotes << quote.number if quote.status == 'draft'
        cancelled_quotes << quote.number if quote.status == 'cancelled'
        quote_latest_activity = PublicActivity::Activity.order("created_at desc").where(:trackable_type => "Quote", :trackable_id => quote.id).first
        quote_items = quote.items.collect { |item| [item.name, item.quantity, item.cost.amount.to_i] }
        if quote_items == orig_items
          report += "\nDuplicate quotes: #{orig_quote_number}(#{quote_1.status}), #{quote.number}(#{quote.status})"
          report += "\n  Time duration between corresponding activities: #{time_diff(quote_1_latest_activity.created_at, quote_latest_activity.created_at)}"
        end
      end
      count += 1 
    end
    Rails.logger.info "\n\n"
    Rails.logger.info report
    Rails.logger.info "Total duplicates found: #{count}"
    Rails.logger.info "Total number of draft quotes: #{draft_quotes.count}"
    Rails.logger.info "Total number of cancelled quotes: #{cancelled_quotes.count}"
    Rails.logger.info "\nDraft quotes: #{draft_quotes.inspect}"
    Rails.logger.info "\nCancelled quotes: #{cancelled_quotes.inspect}"
    puts "\nTask is now completed"
  end

  def time_diff(start_time, end_time)
    seconds_diff = (start_time - end_time).to_i.abs

    hours = seconds_diff / 3600
    seconds_diff -= hours * 3600

    minutes = seconds_diff / 60
    seconds_diff -= minutes * 60

    seconds = seconds_diff

    "#{hours.to_s.rjust(2, '0')}:#{minutes.to_s.rjust(2, '0')}:#{seconds.to_s.rjust(2, '0')}"
  end  
end