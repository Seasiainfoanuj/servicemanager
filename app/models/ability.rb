class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new # guest user (not logged in)

    if user.roles.size == 0

      can :create, Enquiry
      return
    end
    if user.has_role? :admin
      can :manage, :all
    end
    if user.has_role? :admin

      can :manage, :all
      cannot :update, Note do |note|
        note.author_id != user.id
      end
      cannot [:complete, :create_stock], StockRequest

      cannot :manage, QuoteTitlePage do |title_page|
        title_page.try(:quote).try(:master_quote).present?
      end

      cannot :manage, QuoteSummaryPage do |summary_page|
        summary_page.try(:quote).try(:master_quote).present?
      end

      cannot [:create, :update, :destroy], QuoteSpecificationSheet do |specification_sheet|
        specification_sheet.try(:quote).try(:master_quote).present?
      end
    end

     if user.has_role? :supplier

      can :view, :dashboard
      
      can [:create,:read,:complete,:update,:manage], Workorder, :service_provider_id => user.id
      can [:create,:read,:complete], LogUpload, :service_provider_id => user.id
      # can [:create,:update,:complete], WorkorderForm

      can :update, User, :id => user.id
      can :read, [Stock, Vehicle], :supplier_id => user.id
      can [:create, :update, :destroy], Stock, :supplier_id => user.id

      can :manage_notes, Vehicle

      can [:read, :complete, :create_stock], StockRequest, :supplier_id => user.id

      can :read, Quote, :customer_id => user.id
      can :request_change, Quote, :customer_id => user.id
      can :accept, Quote, :customer_id => user.id
      can :update_po, Quote, :customer_id => user.id

      can :create, Enquiry
      can :read, Enquiry, :user_id => user.id

      can :create, Note
      can :update, Note, :author_id => user.id

      can :read, SalesOrder, :customer_id => user.id
     end
    
    if user.has_role? :service_provider

      can :view, :dashboard
      can :view, :schedule

      can :update, User, :id => user.id

      can :manage, PoRequest, :service_provider_id => user.id

      can [:read, :complete, :submit_sp_invoice], Workorder, :service_provider_id => user.id
      can [:read, :complete, :submit_sp_invoice], BuildOrder, :service_provider_id => user.id
      can :manage, BuildOrderUpload
      can [:read, :complete, :submit_sp_invoice], OffHireJob, :service_provider_id => user.id
      can :manage, OffHireJobUpload

      can [:submit, :create], SpInvoice

      can [:read, :update], VehicleLog, :service_provider_id => user.id
      can :manage, LogUpload

      can :read, Quote, :customer_id => user.id
      can :request_change, Quote, :customer_id => user.id
      can :accept, Quote, :customer_id => user.id
      can :update_po, Quote, :customer_id => user.id

      can :read, HireAgreement, :customer_id => user.id
      can [:review, :accept], HireAgreement, :customer_id => user.id

      can :create, Enquiry
      can :read, Enquiry, :user_id => user.id

      can :create, Note
      can :update, Note, :author_id => user.id

      can :read, SalesOrder, :customer_id => user.id
    end

 
    if user.has_role? :employee
      can :view, :dashboard 
      can :read , Quote

      can :create, Enquiry
      can :read, Enquiry, :user_id => user.id
      
      cannot :update, MasterQuote, :employee_id => user.id
      cannot :update, MasterQuoteItem, :employee_id => user.id
      cannot :update, MasterQuoteType, :employee_id => user.id 
      cannot :update, QuoteItemType, :employee_id => user.id 
      
      cannot :update, Note do |note|
        note.author_id != user.id
      end
      cannot [:complete, :create_stock], StockRequest

      cannot :manage, QuoteTitlePage do |title_page|
        title_page.try(:quote).try(:master_quote).present?
      end

      cannot :manage, QuoteSummaryPage do |summary_page|
        summary_page.try(:quote).try(:master_quote).present?
      end

      cannot [:create, :update, :destroy], QuoteSpecificationSheet do |specification_sheet|
        specification_sheet.try(:quote).try(:master_quote).present?
      end

    end
    
    if user.has_role? :customer
      can :view, :dashboard

      can :update, User, :id => user.id

      can :read, Vehicle, :owner_id => user.id
      can :read_schedule, Vehicle, :owner_id => user.id
      can :manage_notes, Vehicle, :owner_id => user.id

      can :read, Workorder, :customer_id => user.id

      can :read, Workorder do |workorder|
        workorder.vehicle.owner_id == user.id
      end

      can :read, Workorder do |workorder|
        workorder.subscribers.include? user
      end

      can :read, BuildOrder do |build_order|
        build_order.subscribers.include? user
      end

      can :read, OffHireJob do |off_hire_job|
        off_hire_job.subscribers.include? user
      end

      can :read, Quote, :customer_id => user.id
      can :request_change, Quote, :customer_id => user.id
      can :accept, Quote, :customer_id => user.id
      can :update_po, Quote, :customer_id => user.id

      can :read, HireQuote do |hire_quote|
        if hire_quote.customer.person?
          hire_quote.customer.user.id == user.id
        else
          hire_quote.authorised_contact.id == user.id
        end
      end

      can :view_customer_quote, HireQuote do |hire_quote|
        if hire_quote.customer.person?
          hire_quote.customer.user.id == user.id
        else
          hire_quote.authorised_contact.id == user.id
        end
      end

      can :request_change, HireQuote do |hire_quote|
        if hire_quote.customer.person?
          hire_quote.customer.user.id == user.id
        else
          hire_quote.authorised_contact.id == user.id
        end
      end

      can :accept, HireQuote do |hire_quote|
        if hire_quote.customer.person?
          hire_quote.customer.user.id == user.id
        else
          hire_quote.authorised_contact.id == user.id
        end
      end

      can :read, VehicleContract, :customer_id => user.id
      can [:show, :view_customer_contract, :review, :accept, :upload_contract], VehicleContract, :customer_id => user.id

      can :read, HireAgreement, :customer_id => user.id
      can [:review, :accept], HireAgreement, :customer_id => user.id

      can :create, Enquiry
      can :read, Enquiry, :user_id => user.id

      can :create, Note
      can :update, Note, :author_id => user.id

      can :read, SalesOrder, :customer_id => user.id
    end

    if user.has_role? :quote_customer

      can :read, Quote, :customer_id => user.id
      can :request_change, Quote, :customer_id => user.id
      can :accept, Quote, :customer_id => user.id
      can :update_po, Quote, :customer_id => user.id

      cannot :show, HireQuote

      can :read, HireQuote do |hire_quote|
        if hire_quote.customer.person?
          hire_quote.customer.user.id == user.id
        else
          hire_quote.authorised_contact.id == user.id
        end
      end

      can :view_customer_quote, HireQuote do |hire_quote|
        if hire_quote.customer.person?
          hire_quote.customer.user.id == user.id
        else
          hire_quote.authorised_contact.id == user.id
        end
      end

      can :request_change, HireQuote do |hire_quote|
        if hire_quote.customer.person?
          hire_quote.customer.user.id == user.id
        else
          hire_quote.authorised_contact.id == user.id
        end
      end

      can :accept, HireQuote do |hire_quote|
        if hire_quote.customer.person?
          hire_quote.customer.user.id == user.id
        else
          hire_quote.authorised_contact.id == user.id
        end
      end

      can :create, Enquiry
      can :read, Enquiry, :user_id => user.id

      can :create, Note
      can :update, Note, :author_id => user.id

      can :read, SalesOrder, :customer_id => user.id
    end
  end
end