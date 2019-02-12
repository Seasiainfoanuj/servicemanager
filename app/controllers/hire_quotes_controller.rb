class HireQuotesController < ApplicationController
  include HireQuotesQueryFormatter
  include HireQuotesHelper

  layout :resolve_layout

  before_action :authenticate_user_from_token!, only: [:view_customer_quote, :request_change, :accept]
  before_action :authenticate_user!
  load_resource :find_by => :reference
  authorize_resource

  before_action :set_hire_quote, only: [:show, :edit, :update, :send_quote, :view_customer_quote, :request_change, :accept, :create_amendment]

  add_crumb('Hire Quotes') { |instance| instance.send :hire_quotes_path }

  def index
    session['last_request'] = '/hire_quotes'

    @filtered_user = User.find(params[:filtered_user_id]) if params[:filtered_user_id]
    if @filtered_user
      add_crumb "Users", users_path
      add_crumb @filtered_user.name, user_path(@filtered_user)
      add_crumb('HireQuotes') { |instance| instance.send :hire_quotes_path }
    end

    @search = get_search_details
    session[:hire_quote_search] = @search
    hire_quotes = get_hire_quotes
    @hire_quotes = hire_quotes.paginate(page: params[:page], per_page: @search.per_page.to_i).order(ordering)
  end 

  def search
    @search = get_search_details
    session[:hire_quote_search] = @search
    hire_quotes = get_hire_quotes
    @hire_quotes = hire_quotes.paginate(page: params[:page], per_page: @search.per_page.to_i).order(ordering)
    render 'index'
  end

  def show
    unless current_user.admin?
     redirect_to(action: :view_customer_quote, id: @hire_quote.reference)
      return
    end
    respond_to do |format|
      format.html do
        add_crumb @hire_quote.reference
        @activities = PublicActivity::Activity.order("created_at desc").where(:trackable_type => "HireQuote", :trackable_id => @hire_quote.id)
      end

      format.pdf do
        pdf = HireQuotePdf.new(@hire_quote, view_context)
        send_data pdf.render, filename: "hire_quote-#{@hire_quote.reference}.pdf",
                              type: "application/pdf", disposition: "inline"
      end
    end
  end

  def view_customer_quote
    unless current_user.admin?
     @hire_quote.create_activity :view, owner: current_user
      @hire_quote.perform_action(:view)
    end
    respond_to do |format|
      format.html

      format.pdf do
        pdf = HireQuotePdf.new(@hire_quote, view_context)
        send_data pdf.render, filename: "hire_quote-#{@hire_quote.reference}.pdf",
                              type: "application/pdf", disposition: "inline"
      end
    end
  end

  def new
    @hire_quote = HireQuote.new
    add_crumb 'New'
  end
  
  def create
    if hire_quote_params[:tags].present?
      unless SearchTag.update_tag_list('hire_quote', hire_quote_params[:tags])
        flash[:error] = "Incorrect tags provided. All tags must be 4 characters or longer."
        render 'new' and return
      end
    end
    if @hire_quote.save
      @hire_quote.create_activity :create, owner: current_user
      flash[:success] = "Hire Quote #{@hire_quote.reference} created."  
      redirect_to(action: :show, id: @hire_quote.reference)
    else
      flash[:error] = "Hire Quote could not be created."
      render 'new'
    end    
  end
  
  def edit
    add_crumb @hire_quote.reference, @hire_quotes
    add_crumb 'Edit'
    @hire_quote.build_cover_letter unless @hire_quote.cover_letter
  end
  
  def update
    if hire_quote_params[:tags].present?
      unless SearchTag.update_tag_list('hire_quote', hire_quote_params[:tags])
        flash[:error] = "Incorrect tags provided. All tags must be 4 characters or longer."
        render 'edit' and return
      end
    end
    customer_changed = hire_quote_params[:customer_id].to_i == @hire_quote.customer_id ? false : true
    original_authorised_contact = @hire_quote.authorised_contact
    if @hire_quote.update(hire_quote_params)
      if customer_changed
        authorised_contact = @hire_quote.reassign_authorised_contact
        original_authorised_contact.assign_hire_quote_role_from(original_authorised_contact)
      end
      @hire_quote.create_activity :update, owner: current_user
      flash[:success] = "Hire Quote #{@hire_quote.reference} updated."
      redirect_to(action: :show, id: @hire_quote.reference)
    else
      flash[:error] = "Hire Quote could not be updated."
      render 'edit'
    end  
  end

  def send_quote
    authorize! :send_quote, HireQuote
    unless @hire_quote.admin_may_perform_action?(:send_quote)
      flash[:error] = "A quote with a status of #{@hire_quote.status} may not be sent."
      redirect_to(:action => 'show', :id => @hire_quote.reference) and return
    end
    if @hire_quote.perform_action(:send_quote)
      @message = params[:message]
      @hire_quote.create_activity :send, recipient: @hire_quote.authorised_contact, owner: current_user
      HireQuoteMailer.delay.quote_email(@hire_quote.authorised_contact.id, @hire_quote.id, @message)
      flash[:success] = "Quote sent to #{@hire_quote.authorised_contact.email}"
    else
      flash[:error] = "Quote could not be accepted. Email has not been sent."
    end
    redirect_to(:action => 'show', :id => @hire_quote.reference)
  end

  def accept
    authorize! :accept, HireQuote
    unless @hire_quote.customer_may_perform_action?(:accept_quote)
      flash[:error] = "A quote with a status of #{@hire_quote.status.titleize} may not be accepted."
      redirect_to(:action => 'show', :id => @hire_quote.reference) and return
    end
    if @hire_quote.perform_action(:accept_quote)
      HireQuoteMailer.delay.accept_notification_email(@hire_quote.manager.user.id, @hire_quote.id)
      hire_company = InvoiceCompany.find_by(slug: 'bus_hire')
      if hire_company.accounts_admin
        HireQuoteMailer.delay.accept_notification_email(hire_company.accounts_admin.id, @hire_quote.id)
      end
      @hire_quote.create_activity :accept, owner: current_user
      flash[:success] = "Quote accepted. The Hire Manager has been informed."
    else
      flash[:error] = "Hire Quote could not be accepted. Please contact the Hire Manager."
    end
    if params[:user_email].present? and params[:user_token].present?
      redirect_to(:action => 'view_customer_quote', :id => @hire_quote.reference, :user_email => params[:user_email], :user_token => params[:user_token], :referrer => "accepted")
    else
      redirect_to(:action => 'view_customer_quote', :id => @hire_quote.reference, :referrer => "accepted")
    end
  end

  def request_change
    authorize! :request_change, HireQuote
    unless @hire_quote.customer_may_perform_action?(:request_changes)
      flash[:error] = "Changes are not permitted on a quote with a status of #{@hire_quote.status.titleize}."
      redirect_to(:action => 'view_customer_quote', :id => @hire_quote.reference) and return
    end
    formatted_message = change_request_message_formatted(current_user, changed_message_params)

    if @hire_quote.perform_action(:request_changes)
      HireQuoteMailer.delay.request_changes_email(@hire_quote.id, current_user.id, formatted_message)
      @hire_quote.create_activity :request_change, owner: current_user
      flash[:success] = "Changes have been requested. We will be in touch with you shortly. Thank you."
      redirect_to(:action => 'view_customer_quote', :id => @hire_quote.reference, :user_email => params[:user_email], :user_token => params[:user_token], :referrer => "request_change")
    else
      redirect_to(:action => 'view_customer_quote', :id => @hire_quote.reference, :referrer => "request_change")
    end
  end

  def create_amendment
    authorize! :create_amendment, HireQuote
    unless @hire_quote.admin_may_perform_action?(:create_amendment)
      flash[:error] = "An amendment may not be done on a quote with a status of #{@hire_quote.status.titleize}."
      redirect_to(:action => 'show', :id => @hire_quote.reference) and return
    end
    if @hire_quote.perform_action(:cancel_quote)
      @hire_quote.create_activity :cancel, owner: current_user
      amendment_quote = HireQuoteManager.create_amendment(@hire_quote)
      amendment_quote.create_activity :amended, owner: current_user
      flash[:success] = "Hire Quote #{@hire_quote.reference} has been cancelled and a new version has been created. You may now proceed to update amended quote #{amendment_quote.reference}."
      redirect_to(:action => 'show', :id => amendment_quote.reference)
    else
      flash[:error] = "There was a problem creating the amendment."
      redirect_to(:action => 'show', :id => @hire_quote.reference)
    end
  end

  private

    def set_hire_quote
      @hire_quote = HireQuote.find_by(reference: params[:id])
    end

    def search_params
      params.require(:hire_quote_search).permit(
        :reference, :customer_name, :manager_name, :company_name, :status,
        :show_all, :sort_field, :direction, :per_page, :defaults, :tags => []
        )
    end

    def changed_message_params
      params.permit(
        :first_name, :last_name, :mobile, :message)
    end

    def hire_quote_params
      params.require(:hire_quote).permit(
        :customer_id,
        :manager_id,
        :authorised_contact_id,
        :enquiry_id,
        :last_viewed_field,
        :tags,
        cover_letter_attributes: [
          :covering_subject_id,
          :covering_subject_type,
          :title,
          :content ]
        )
    end

    def resolve_layout
      case action_name
      when "view_customer_quote"
        "clean"
      else
        "application"
      end
    end

    def authenticate_user_from_token!
      user_email = params[:user_email].presence
      user  = user_email && User.find_by(email: user_email)
      hire_quote = derive_quote_from_params
      if hire_quote && user && valid_client?(hire_quote, user)
        sign_in user, store: false if Devise.secure_compare(user.authentication_token, params[:user_token])
      end
    end

    def valid_client?(hire_quote, user)
      if hire_quote.customer.person?
        valid_client = hire_quote.customer.user == user
      else
        valid_client = hire_quote.authorised_contact == user
      end
    end

    def derive_quote_from_params
      if params[:id].presence
        quote_id = params[:id]
      elsif params[:hire_quote_id].presence
        quote_id = params[:hire_quote_id]
      else
        quote_id = nil
      end
      HireQuote.find_by(reference: quote_id) if quote_id
    end

end
