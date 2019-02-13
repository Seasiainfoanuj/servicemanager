namespace :change_workorders do

  desc "Change all pending Workorder statuses to confirmed"
  task "convert_pending_to_confirmed" => :environment do

    pending_workorders = Workorder.where(status: 'pending')
    pending_count = pending_workorders.count
    puts "Number of pending workorders: #{pending_count}"
    pending_workorders.each do |wo|
      wo.status = 'draft'
      wo.save
    end
    pending_count = Workorder.where(status: 'pending').count
    puts "After conversion: Number of pending workorders: #{pending_count}"
    draft_count = Workorder.where(status: 'draft').count
    puts "After conversion: Number of draft workorders: #{draft_count}"

  end
end