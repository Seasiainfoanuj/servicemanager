class DashboardController < ApplicationController

  before_filter :authenticate_user!

  add_crumb "Dashboard"

  def index
    if current_user.has_role? :dealer
      @enquiry_stats = get_enquiries_dealers
    else
      @enquiry_stats = get_enquiries
    end
  end

  def changelog
    authorize! :view, :changelog
  end

  def privacy_statement
    if current_user
      @user = "#{current_user.first_name} #{current_user.last_name}, #{current_user.email}"
    else
      @user = "Your name, email"
    end  
  end

  private

    def get_enquiries
      enquiries = Enquiry.where(status: ['new', 'pending', 'waiting response', 'quoted'])
                  .select("origin, status, seen, count(id) AS total")
                  .group('origin, status, seen')
                  .order('origin, status, seen')
      origin_names = { 0 => 'Service Manager', 1 => 'CMS', 2 => 'IBUS' }
      stats = { new_not_read: { }, new_but_read: { }, pending: { }, awaiting_response: { }, quoted: { } }
      enquiries.each do |enquiry| 
        case enquiry.status
        when 'new'
          if enquiry.seen
            stats[:new_but_read][origin_names[enquiry.origin]] = enquiry.total
          else
            stats[:new_not_read][origin_names[enquiry.origin]] = enquiry.total
          end  
        when 'pending'
          stats[:pending][origin_names[enquiry.origin]] = enquiry.total
        when 'waiting response'
          stats[:awaiting_response][origin_names[enquiry.origin]] = enquiry.total
        when 'quoted'
          stats[:quoted][origin_names[enquiry.origin]] = enquiry.total 
        end
      end  
      stats
    end

    def get_enquiries_dealers

      enquiries_id = Enquiry.where('user_id = :current_user OR manager_id = :current_user', current_user: current_user.id)

      enquiries = enquiries_id.where(status: ['new', 'pending', 'waiting response', 'quoted'])
                  .select("origin, status, seen, count(id) AS total")
                  .group('origin, status, seen')
                  .order('origin, status, seen')
      origin_names = { 0 => 'Service Manager', 1 => 'CMS', 2 => 'IBUS' }
      stats = { new_not_read: { }, new_but_read: { }, pending: { }, awaiting_response: { }, quoted: { } }
      enquiries.each do |enquiry| 
        case enquiry.status
        when 'new'
          if enquiry.seen
            stats[:new_but_read][origin_names[enquiry.origin]] = enquiry.total
          else
            stats[:new_not_read][origin_names[enquiry.origin]] = enquiry.total
          end  
        when 'pending'
          stats[:pending][origin_names[enquiry.origin]] = enquiry.total
        when 'waiting response'
          stats[:awaiting_response][origin_names[enquiry.origin]] = enquiry.total
        when 'quoted'
          stats[:quoted][origin_names[enquiry.origin]] = enquiry.total 
        end
      end  
      stats
    end
end
