class ClientPresenter < BasePresenter
  delegate :link_to, to: :@view

  def initialize(model, view)
    super
  end

  def user_company_name
    user_company.name if user_company
  end

  def email
    user.email if user
  end

  def user_company_label
    if employee?
      'Employed by'
    elsif user.contact?
      'Contact for'
    elsif user_company 
      'Works for'
    end  
  end

end

