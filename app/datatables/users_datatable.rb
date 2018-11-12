include UsersHelper
class UsersDatatable 
  
  delegate :params, :h, :link_to, :can?, :mail_to, :content_tag, :image_tag, to: :@view

  def initialize(view, current_user, users)
    @view = view
    @current_user = current_user
    @user_ids = users.map { |user| user.id }
  end

  def as_json(options = {})
    {
      draw: params[:draw].to_i,
      recordsTotal: new_total_records,
      recordsFiltered: users.total_entries,
      data: data
    }
  end

  private

    def data
      users.where(archived_at: nil).map do |user|
        [
          avatar(user),
          user.first_name,
          user.last_name,
          user.representing_company_name,
          user.job_title,
          user.email,
          user.phone,
          roles(user),
          action_links(user)
        ]
      end
    end

    def avatar(user)
      image_tag user.avatar.url(:small), style: 'width: 30px; max-width: 30px;'
    end

    def roles(user)
      result = user.roles.map { |role| role.to_s.humanize }
      result.to_sentence
    end

    def action_links(user)
      mail_link(user) + view_link(user) + edit_link(user) + archive_link(user)
    end

    def mail_link(user)
      mail_to user.email, content_tag(:i, nil, class: 'icon-envelope'), {:title => 'Email', :class => 'btn', 'rel' => 'tooltip', :style => 'margin-right: 5px;'}
    end

    def view_link(user)
      link_to content_tag(:i, nil, class: 'icon-search'), user, {:title => 'View', :class => 'btn action-link'}
    end

    def edit_link(user)
      if can? :update, User
        link_to content_tag(:i, nil, class: 'icon-edit'), {controller: "users", action: "edit", id: user.id}, {:title => 'Edit', :class => 'btn action-link'}
      end
    end

    def archive_link(user)
      if can? :destroy, User
        link_to content_tag(:i, nil, class: 'icon-ban-circle'), user, method: :delete, :id => "user-#{user.id}-del-btn", :class => "btn action-link user-#{user.id}-del-btn", :title => 'Archive', 'rel' => 'tooltip', :data => {confirm: "You are about to archive the user, #{user.name}. You cannot reverse this action. Are you sure you want to proceed?"}
      end
    end

    def users
      @users ||= fetch_users
    end

    def fetch_users
      users = init_users

      if params[:search] && params[:search][:value].present?
      rows = %w[ first_name
                  last_name
                  companies.name
                  job_title
                  email
                  phone
               ]

      terms = params[:search][:value].split
      search_params  = {}
      terms.each_with_index { |term, index| search_params["search#{index}".to_sym] = "%#{term}%" }
      search = terms.map.with_index {|term, index| "(" + rows.map { |row| "#{row} like :search#{index}" }.join(" or ") + ")" }.join(" and ")

      users = users.where(search, search_params).order("#{sort_column} #{sort_direction}")
      end

      users.page(page).per_page(per_page)
    end

    def init_users
      @pre_users ||= pre_users
    end

    def pre_users
      sel_str = "users.id, users.first_name, users.last_name, users.job_title, 
                 users.avatar_file_name, users.email, users.phone, users.roles_mask,
                 users.representing_company_id, companies.name AS representing_company_name"
      users = User.select(sel_str)
          .joins("LEFT JOIN companies on users.representing_company_id = companies.id") 

      users.where(id: @user_ids).order("#{sort_column} #{sort_direction}")
    end

    def total_records
      init_users.count
    end
    
    def new_total_records
      sel_str = "users.id"
      users = User.select(sel_str)
          .joins("LEFT JOIN companies on users.representing_company_id = companies.id") 

      users = users.where(id: @user_ids).order("#{sort_column} #{sort_direction}")
          
      users = users.count
    end
   
    def page
      params[:start].to_i/per_page + 1
    end

    def per_page
      params[:length].to_i > 0 ? params[:length].to_i : 10
    end

    def sort_column
      if params[:order] && params[:order]["0"] && params[:order]["0"][:column]
        columns = %w[id first_name last_name representing_company_name job_title email phone]
        columns[params[:order]["0"][:column].to_i]
      end
    end

    def sort_direction
      if params[:order] && params[:order]["0"] && params[:order]["0"][:dir]
      params[:order]["0"][:dir] == "asc" ? "asc" : "desc"
    end
    end
end