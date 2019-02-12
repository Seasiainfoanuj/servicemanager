module VehicleContractsHelper

  def vehicle_contract_status_label(status)
    if status == "draft"
      "<span class='label label-warning'>#{status.titleize}</span>".html_safe
    elsif status == "verified"
      "<span class='label label-blue'>#{status.titleize}</span>".html_safe
    elsif status == "presented_to_customer"
      "<span class='label label-satgreen'>#{status.titleize}</span>".html_safe
    elsif status == "signed"
      "<span class='label label-green'>#{status.titleize}</span>".html_safe
    elsif status == "declined"
      "<span class='label label-lightred'>#{status.titleize}</span>".html_safe
    else
      "<span class='label'>#{status.titleize}</span>".html_safe
    end
  end

  def content_tag_for_review_and_sign(contract, user)
    contract_params_admin = { controller: "vehicle_contracts", action: "review", id: contract.uid }
    contract_params_customer = contract_params_admin.merge({ 
        user_email: contract.customer.email, user_token: contract.customer.authentication_token })
    html_params = {:title => 'Review Contract', :class => 'btn btn-satgreen submit-btn'}
    if user == contract.customer
      contract_params = contract_params_customer
    elsif current_user.admin?
      contract_params = contract_params_admin
    else
      return nil
    end
    [content_tag(:i, 'Review and Sign Contract...', class: 'icon-ok').html_safe, contract_params, html_params]
  end

end
