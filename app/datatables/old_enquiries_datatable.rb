include EnquiriesHelper
class EnquiriesDatatable
  delegate Fixnum, :params, :h, :can?, :link_to, :number_to_currency, :content_tag, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
    @filtered_user = User.find(params[:filtered_user]) if params[:filtered_user]
    @enquiry = Enquiry.manager.name if enquiry.manager.present?
  end

  def as_json(options = {})
    {
      draw: params[:draw].to_i,
      recordsTotal: total_entries,
      recordsFiltered: enquiries.total_entries,
      data: data
    }
  end

private

  def data
    if @current_user.has_role?(:admin)
      enquiries.map do |enquiry|
        [
          read_column(enquiry),
          enquiry_flagged_icon(enquiry),
          uid(enquiry),
          status_label(enquiry),
          enquiry.enquiry_type.name,
          full_name(enquiry),
          enquiry.company,
          enquiry.email,
          manager(enquiry),
          score(enquiry),
          date(enquiry),
          enquiry.tag_names,
          action_links(enquiry)
        ]
      end
    else
      enquiries.map do |enquiry|
        [
          uid(enquiry),
          enquiry.enquiry_type.name,
          full_name(enquiry),
          enquiry.company,
          enquiry.email,
          manager(enquiry),
          score(enquiry),
          date(enquiry),
          action_links(enquiry)
        ]
      end
    end
  end

  def read_column(enquiry)
    if enquiry.seen == false && @current_user.has_role?(:admin)
      content_tag(:i, "", class: 'icon-circle', style: "color: red; font-size: 10px;")
    end
  end

  def status_label(enquiry)
    enquiry_status_label(enquiry.status) if enquiry.status
  end
  def score(enquiry)
    enquiry_score_label(enquiry.score) if enquiry.score
  end

  def action_links(enquiry)
    view_link(enquiry) + edit_link(enquiry) + destroy_link(enquiry)
  end

  def view_link(enquiry)
    link_to content_tag(:i, nil, class: 'icon-search'), enquiry, {:title => 'View', :class => 'btn action-link'}
  end

  def edit_link(enquiry)
    if can? :update, Enquiry
      link_to content_tag(:i, nil, class: 'icon-edit'), {controller: "enquiries", action: "edit", id: enquiry.uid}, {:title => 'Edit', :class => 'btn action-link'}
    end
  end

  def edit_link(enquiry)
    if can? :update, Enquiry
      link_to content_tag(:i, nil, class: 'icon-edit'), {controller: "enquiries", action: "edit", id: enquiry.uid}, {:title => 'Edit', :class => 'btn action-link'}
    end
  end

  def destroy_link(enquiry)
    if can? :destroy, Enquiry
      link_to content_tag(:i, nil, class: 'icon-ban-circle'), enquiry, method: :delete, :id => "enquiry-#{enquiry.id}-del-btn", :class => 'btn action-link', :title => 'Destroy', 'rel' => 'tooltip', data: {confirm: "You are about to permanently delete enquiry number #{enquiry.uid}. You cannot reverse this action. Are you sure you want to proceed?"}
    end
  end

  def uid(enquiry)
    link_to content_tag(:span, enquiry.uid, class: 'label label-grey'), enquiry
  end

  def full_name(enquiry)
    "#{enquiry.first_name} #{enquiry.last_name}"
  end

  def manager(enquiry)
    enquiry.manager.name if enquiry.manager.present?
  end

  def date(enquiry)
    "#{content_tag(:span, enquiry.created_at.strftime("%Y-%m-%d %H:%M"), class: 'hidden')}
        #{enquiry.date}"
  end

  def total_entries
    init_enquiries.count.length
  end

  def enquiries
    @enquiries ||= fetch_enquiries
  end

  def fetch_enquiries
    enquiries = init_enquiries

    if params[:showAll] && params[:showAll] == 'false'
      enquiries = enquiries.where("status != 'closed'")
    end

    if params[:search] && params[:search][:value].present?
      rows = %w[ uid
                 status
                 enquiry_types.name
                 enquiries.first_name
                 enquiries.last_name
                 enquiries.company
                 enquiries.email
                 enquiries.phone
                 users.first_name
                 users.last_name
                 user_company
                 user_email
                 tag_names
               ]

      terms = params[:search][:value].split
      search_params  = {}
      terms.each_with_index { |term, index| search_params["search#{index}".to_sym] = "%#{term}%" }
      search = terms.map.with_index {|term, index| "(" + rows.map { |row| "#{row} like :search#{index}" }.join(" or ") + ")" }.join(" and ")

      enquiries = enquiries.having(search, search_params)
      count = enquiries.length
    end

    enquiries = enquiries.page(page).per_page(per_page).order("#{sort_column} #{sort_direction}")
    enquiries.total_entries = count || enquiries.count.length
    enquiries
  end

  def init_enquiries
    @pre_enquiries ||= pre_enquiries
  end

  def pre_enquiries
    sel_str = "enquiries.id, enquiries.uid, enquiries.status, enquiries.seen, enquiries.flagged, enquiry_types.name AS enquiry_type,
               enquiries.enquiry_type_id, enquiries.first_name, enquiries.last_name,
               CONCAT(enquiries.first_name, ' ', enquiries.last_name) AS full_name,
               users.first_name as user_first_name, users.last_name as user_last_name, users.company as user_company, users.email as user_email,
               CONCAT(users.first_name, ' ', users.last_name) AS manager,
               enquiries.company, enquiries.email, enquiries.phone,
               enquiries.manager_id, enquiries.created_at,
               tags.id, taggings.tag_id, GROUP_CONCAT(tags.name SEPARATOR ', ') AS tag_names"

    enquiries = Enquiry.select(sel_str)
                       .joins("LEFT JOIN enquiry_types on enquiries.enquiry_type_id = enquiry_types.id")
                       .joins("LEFT JOIN users on enquiries.manager_id = users.id")
                       .joins("LEFT JOIN taggings on taggings.taggable_id = enquiries.id and taggings.taggable_type = 'Enquiry'")
                       .joins("LEFT JOIN tags on taggings.tag_id = tags.id")
                       .group('enquiries.id')

    enquiries = enquiries.where('user_id = :user', user: @current_user.id) unless @current_user.has_role? :admin
    enquiries = enquiries.where('manager_id = :user or user_id = :user', user: @filtered_user.id) if @filtered_user
    enquiries
  end

  def page
    params[:start].to_i/per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end

  def sort_column
    if params[:order] && params[:order]["0"] && params[:order]["0"][:column]
      columns = %w[enquiries.created_at flagged uid status enquiry_type full_name company email manager enquiries.created_at tag_names]
      columns[params[:order]["0"][:column].to_i]
    end
  end

  def sort_direction
    if params[:order] && params[:order]["0"] && params[:order]["0"][:dir]
      params[:order]["0"][:dir] == "asc" ? "asc" : "desc"
    end
  end
end
