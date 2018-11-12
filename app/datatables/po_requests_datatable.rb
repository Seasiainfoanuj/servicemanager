include PoRequestsHelper
class PoRequestsDatatable
  delegate :params, :h, :link_to, :can?, :content_tag, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
    @filtered_user = User.find(params[:filtered_user]) if params[:filtered_user]
  end

  def as_json(options = {})
    {
      draw: params[:draw].to_i,
      recordsTotal: new_total_entries,
      recordsFiltered: po_requests.total_entries,
      data: data
    }
  end

  private

    def data
      if @current_user.has_role?(:admin)
        po_requests.map do |po_request|
          [
            read_column(po_request),
            po_request_flagged_icon(po_request),
            uid_label(po_request),
            status_label(po_request),
            service_provider_link(po_request),
            vehicle_make_and_model(po_request),
            vehicle_vin_number(po_request),
            scheduled(po_request),
            etc(po_request),
            po_request.tag_names,
            action_links(po_request)
          ]
        end
      else
        po_requests.map do |po_request|
          [
            uid_label(po_request),
            status_label(po_request),
            service_provider_link(po_request),
            vehicle_make_and_model(po_request),
            po_request.vehicle_vin_number,
            scheduled(po_request),
            etc(po_request),
            action_links(po_request)
          ]
        end
      end
    end

    def read_column(po_request)
      if po_request.read == false && @current_user.has_role?(:admin)
        content_tag(:i, "", class: 'icon-circle', style: "color: red; font-size: 10px;")
      end
    end

    def uid_label(po_request)
      link_to content_tag(:span, po_request.uid, class: 'label label-grey'), po_request
    end

    def status_label(po_request)
      po_request_status_label(po_request.status) if po_request.status.present?
    end

    def service_provider_link(po_request)
      if can? :view, po_request.service_provider
        link_to po_request.service_provider.company_name_short, po_request.service_provider
      else
        po_request.service_provider.company_name_short
      end
    end

    def vehicle_make_and_model(po_request)
      "#{po_request.vehicle_make} #{po_request.vehicle_model}"
    end

    def vehicle_vin_number(po_request)
      unless po_request.vehicle_id.present?
        content_tag(:span, content_tag(:i, nil, class: 'icon-warning-sign') + " #{po_request.vehicle_vin_number}".html_safe, class: 'label label-warning has-tooltip', title: 'No vehicle found in system')
      else
        content_tag(:span, po_request.vehicle_vin_number, class: 'label')
      end
    end

    def scheduled(po_request)
      "#{po_request.sched_date_field} - #{po_request.sched_time_field}"
    end

    def etc(po_request)
      "#{po_request.etc_date_field} - #{po_request.etc_time_field}"
    end

    def action_links(po_request)
      view_link(po_request) + edit_link(po_request) + destroy_link(po_request)
    end

    def view_link(po_request)
      link_to content_tag(:i, nil, class: 'icon-search'), po_request, {:title => 'View', :class => 'btn action-link'}
    end

    def edit_link(po_request)
      if can? :update, po_request
        link_to content_tag(:i, nil, class: 'icon-edit'), {controller: "po_requests", action: "edit", id: po_request.uid}, {:title => 'Edit', :class => 'btn action-link'}
      end
    end

    def destroy_link(po_request)
      if can? :destroy, po_request
        link_to content_tag(:i, nil, class: 'icon-ban-circle'), po_request, method: :delete, :id => "po_request-#{po_request.id}-del-btn", :class => 'btn action-link po_request-#{po_request.id}-del-btn', :title => 'Destroy', 'rel' => 'tooltip', data: {confirm: "You are about to permanently delete po request ##{po_request.uid}. You cannot reverse this action. Are you sure you want to proceed?"}
      end
    end

    def total_records
       init_po_requests.count.length
    end

    def po_requests
      @po_requests ||= fetch_po_requests
    end

    def fetch_po_requests
      po_requests = init_po_requests
      if params[:search] && params[:search][:value].present?
        rows = %w[ uid
                   status
                   service_providers.company
                   service_providers.first_name
                   service_providers.last_name
                   vehicle_make
                   vehicle_vin_number
                   sched_time
                   etc
                   tag_names
                 ]

        terms = params[:search][:value].split
        search_params  = {}
        terms.each_with_index { |term, index| search_params["search#{index}".to_sym] = "%#{term}%" }
        search = terms.map.with_index {|term, index| "(" + rows.map { |row| "#{row} LIKE :search#{index}" }.join(" OR ") + ")" }.join(" AND ")

        # po_requests = po_requests.where(search, search_params).order("#{sort_column} #{sort_direction}")
        po_requests = po_requests.having(search, search_params)
        count = po_requests.length
      end

      # po_requests.page(page).per_page(per_page)
      po_requests = po_requests.page(page).per_page(per_page).order("#{sort_column} #{sort_direction}")
      po_requests.total_entries = count || po_requests.count.length
      po_requests
    end

    def init_po_requests
      @pre_po_requests ||= pre_po_requests
    end

    def pre_po_requests
      sel_str = "po_requests.id, po_requests.uid, po_requests.status, po_requests.read, po_requests.flagged, po_requests.service_provider_id, po_requests.created_at,
                 po_requests.sched_time, po_requests.etc, po_requests.vehicle_id, po_requests.vehicle_make, po_requests.vehicle_model, po_requests.vehicle_vin_number,
                 service_providers.company, service_providers.first_name, service_providers.last_name,
                 CONCAT(service_providers.company, service_providers.first_name, ' ', service_providers.last_name) AS service_provider_name,
                 tags.id, taggings.tag_id, GROUP_CONCAT(tags.name SEPARATOR ', ') AS tag_names"

      po_requests = PoRequest.select(sel_str)
                             .joins("LEFT JOIN users AS service_providers on po_requests.service_provider_id = service_providers.id")
                             .joins("LEFT JOIN taggings on taggings.taggable_id = po_requests.id and taggings.taggable_type = 'PoRequest'")
                             .joins("LEFT JOIN tags on taggings.tag_id = tags.id")
                             .group('po_requests.id')

      if @current_user.has_role? :admin
        po_requests = po_requests
      else
        po_requests = po_requests.where(service_provider_id: @current_user.id)
      end

      po_requests = po_requests.where('service_provider_id = :user', user: @filtered_user.id) if @filtered_user

      if params[:showAll] && params[:showAll] == 'false'
        po_requests.where("status != 'closed'")
      else
        po_requests
      end
    end
    def new_total_entries
      sel_str = "po_requests.id"

      po_requests = PoRequest.select(sel_str)
                             .joins("LEFT JOIN users AS service_providers on po_requests.service_provider_id = service_providers.id")
                             .joins("LEFT JOIN taggings on taggings.taggable_id = po_requests.id and taggings.taggable_type = 'PoRequest'")
                             .joins("LEFT JOIN tags on taggings.tag_id = tags.id")
                             .group('po_requests.id')

      if @current_user.has_role? :admin
        po_requests =  po_requests
      else
        po_requests = po_requests.where(service_provider_id: @current_user.id)
       
      end
        po_requests = po_requests.where('service_provider_id = :user', user: @filtered_user.id) if @filtered_user
       
      if params[:showAll] && params[:showAll] == 'false'
        po_requests =   po_requests.where("status != 'closed'")
        po_requests.count
      else
         po_requests.count
      end
    end


    def page
      params[:start].to_i/per_page + 1
    end

    def per_page
      params[:length].to_i > 0 ? params[:length].to_i : 10
    end

    def sort_column
      if params[:order] && params[:order]["0"] && params[:order]["0"][:column]
        columns = %w[ po_requests.created_at
                      flagged
                      uid
                      status
                      service_provider_name
                      vehicle_make
                      vehicle_vin_number
                      sched_time
                      etc
                      tag_names
                    ]
        columns[params[:order]["0"][:column].to_i]
      end
    end

    def sort_direction
      if params[:order] && params[:order]["0"] && params[:order]["0"][:dir]
        params[:order]["0"][:dir] == "asc" ? "asc" : "desc"
      end
    end
end
