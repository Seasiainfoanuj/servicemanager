module EnquiriesHelper
  def enquiry_status_label(status)
    case status
    when "new"
      content_tag(:span, status.titleize, class: 'label label-green')
    when "emailed"
      content_tag(:span, status.titleize, class: 'label label-satblue')
    when "pending"
      content_tag(:span, status.titleize, class: 'label label-warning')
    when "waiting response"
      content_tag(:span, status.titleize, class: 'label label-important')
    when "pending quote"
      content_tag(:span, status.titleize, class: 'label label-blue')
    when "quoted"
      content_tag(:span, status.titleize, class: 'label label-blue')
    when "closed"
      content_tag(:span, status.titleize, class: 'label')
    else
      content_tag(:span, "status unknown", class: 'label')
    end
  end

  def enquiry_score_label(score)
    case score
    when "cold"
      content_tag(:span, link_to(image_tag('flame1.png')))
    when "warm"
      content_tag(:span, link_to(image_tag('flame2.png')))
    when "hot"
      content_tag(:span, link_to(image_tag('flame3.png')))
    else
      content_tag(:span, "Score unknown", class: 'label label-warning') 
    end
  end

  def enquiry_flagged_icon(enquiry)
    if enquiry.flagged == true
      content_tag(:i, nil, class: 'glyphicon-flag', style: 'color: #D97A46')
    else
      "" #return empty string
    end
  end

  def new_enquiries_count
    Enquiry.new_not_read.count
  end
 
  def enquiries_count( options = {} )
    case options[:filter]
    when :new_not_read
      enquiries_new_not_read = Enquiry.new_not_read
      enquiries_sm = enquiries_new_not_read.from_service_manager.count
      enquiries_cms = enquiries_new_not_read.from_cms.count
      enquiries_ibus = enquiries_new_not_read.from_ibus.count
      { all: (enquiries_sm + enquiries_cms + enquiries_ibus), service_manager: enquiries_sm, cms: enquiries_cms, ibus: enquiries_ibus }
    when :new_but_read
      enquiries_new_but_read = Enquiry.new_but_read
      enquiries_sm = enquiries_new_but_read.from_service_manager.count
      enquiries_cms = enquiries_new_but_read.from_cms.count
      enquiries_ibus = enquiries_new_but_read.from_ibus.count
      { all: (enquiries_sm + enquiries_cms + enquiries_ibus), service_manager: enquiries_sm, cms: enquiries_cms, ibus: enquiries_ibus }
    when :pending
      enquiries_pending = Enquiry.pending
      enquiries_sm = enquiries_pending.from_service_manager.count
      enquiries_cms = enquiries_pending.from_cms.count
      enquiries_ibus = enquiries_pending.from_ibus.count
      { all: (enquiries_sm + enquiries_cms + enquiries_ibus), service_manager: enquiries_sm, cms: enquiries_cms, ibus: enquiries_ibus }
    when :awaiting_response
      enquiries_pending = Enquiry.awaiting_response
      enquiries_sm = enquiries_pending.from_service_manager.count
      enquiries_cms = enquiries_pending.from_cms.count
      enquiries_ibus = enquiries_pending.from_ibus.count
      { all: (enquiries_sm + enquiries_cms + enquiries_ibus), service_manager: enquiries_sm, cms: enquiries_cms, ibus: enquiries_ibus }
    when :quoted
      enquiries_quoted = Enquiry.quoted
      enquiries_sm = enquiries_quoted.from_service_manager.count
      enquiries_cms = enquiries_quoted.from_cms.count
      enquiries_ibus = enquiries_quoted.from_ibus.count
      { all: (enquiries_sm + enquiries_cms + enquiries_ibus), service_manager: enquiries_sm, cms: enquiries_cms, ibus: enquiries_ibus }
    end
  end


  def enquiries_label( content, options = {} )
    case options[:filter]
    when :new_not_read
      content_tag(:span, content, class: 'label label-lightred label-small', style: "margin-left: 3px;")
    when :new_but_read
      content_tag(:span, content, class: 'label label-orange label-small', style: "margin-left: 3px;")
    when :pending
      content_tag(:span, content, class: 'label label-blue label-small', style: "margin-left: 3px;")
    when :awaiting_response
      content_tag(:span, content, class: 'label label-blue label-small', style: "margin-left: 3px;")
    when :quoted
      content_tag(:span, content, class: 'label label-green label-small', style: "margin-left: 3px;")
    end  
  end

  def new_enquiries_label(new_enquiries_count)
    content_tag(:span, new_enquiries_count, class: 'label label-lightred')
  end

  def new_enquiries_label_small(new_enquiries_count)
    content_tag(:span, "#{new_enquiries_count} Unread", class: 'label label-lightred label-small', style: "margin-left: 3px;") if new_enquiries_count > 0
  end

  def flagged_enquiries_count
    Enquiry.where(flagged: true).count
  end

  def flagged_enquiries_label(flagged_enquiries_count)
    content_tag(:span, flagged_enquiries_count, class: 'label label-orange') if flagged_enquiries_count > 0
  end

  def flagged_enquiries_label_small(flagged_enquiries_count)
    content_tag(:span, "#{flagged_enquiries_count} <i class='icon-flag'></i>".html_safe, class: 'label label-orange label-small', style: "margin-left: 3px;") if flagged_enquiries_count > 0
  end

  def enquiry_action_links(enquiry)
   if (current_user.has_role? :admin, :employee)&& ( !current_user.has_role?  :masteradmin, :superadmin) 
      if ((enquiry.user.present? && current_user.id == enquiry.user.id) || (enquiry.manager.present? && current_user.id == enquiry.manager.id))
       view_enquiry_link(enquiry) + edit_enquiry_link(enquiry) + destroy_enquiry_link(enquiry)
      else
       view_enquiry_link(enquiry) + destroy_enquiry_link(enquiry)
      end
   else
       view_enquiry_link(enquiry) + edit_enquiry_link(enquiry) + destroy_enquiry_link(enquiry)  
   end   
  end

  def view_enquiry_link(enquiry)
    link_to content_tag(:i, nil, class: 'icon-search'), enquiry, {:title => 'View', :class => 'btn action-link'}
  end

  def edit_enquiry_link(enquiry)
    if can? :update, Enquiry
      link_to content_tag(:i, nil, class: 'icon-edit'), {controller: "enquiries", action: "edit", id: enquiry.uid}, {:title => 'Edit', :class => 'btn action-link'}
    end
  end

  def destroy_enquiry_link(enquiry)
    if can? :destroy, Enquiry
      link_to content_tag(:i, nil, class: 'icon-ban-circle'), enquiry, method: :delete, :id => "enquiry-#{enquiry.id}-del-btn", :class => 'btn action-link', :title => 'Destroy', 'rel' => 'tooltip', data: {confirm: "You are about to permanently delete enquiry number #{enquiry.uid}. You cannot reverse this action. Are you sure you want to proceed?"}
    end
  end

  def enquiry_reference_label(enquiry)
    content_tag(:span, enquiry.uid, class: 'header-label label-blue')
  end

end
