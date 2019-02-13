class EnquiriesController < ApplicationController
  include EnquiryActions
  include EnquiriesQueryFormatter
  layout :resolve_layout
  before_action :authenticate_user!, except: [:new, :create, :enquiry_submitted]
  load_resource :find_by => :uid
  authorize_resource
  skip_authorize_resource :only => :enquiry_submitted

  before_action :set_enquiry, only: [:show, :edit, :update, :destroy, :create_hire_quote, :show_activitiess]
  
  add_crumb("Enquiries") { |instance| instance.send :enquiries_path }

  def index
    @filtered_user = User.find(params[:filtered_user_id]) if params[:filtered_user_id]
    if @filtered_user
      add_crumb "Users", users_path
      add_crumb @filtered_user.name, user_path(@filtered_user)
      add_crumb('Enquiries') { |instance| instance.send :enquiries_path }
    end

    @search = get_search_details
    session[:search] = @search
    unless current_user.has_role? :dealer
      enquiries = get_enquiries
    else
      enquiries = get_enquiries_dealers
    end
    @enquiries = enquiries.paginate(page: params[:page], per_page: @search.per_page.to_i).order(ordering)
  end

  def search
    @filtered_user = User.find(params[:filtered_user_id]) if params[:filtered_user_id]
    if @filtered_user
      add_crumb "Users", users_path
      add_crumb @filtered_user.name, user_path(@filtered_user)
      add_crumb('Search Enquiries') { |instance| instance.send :enquiries_path }
    end

    @search = get_search_details
    session[:search] = @search
    enquiries = get_enquiries
    @enquiries = enquiries.paginate(page: params[:page], per_page: @search.per_page.to_i).order(ordering)
    render 'index'
  end

  def show
    @activities = PublicActivity::Activity.order("created_at desc")
                    .where(:trackable_type => "Enquiry", :trackable_id => @enquiry.id)
                    .where("created_at > ?", Date.today - 6.months)

    session['last_request'] = "/enquiries/#{@enquiry.uid}"
    session['current_enquiry'] = @enquiry.id

    if current_user.has_role? :admin
      unless params[:referer] == "update" || params[:referer] == "assign"
        unless @enquiry.seen == true
          @enquiry.update(seen: true)
          @enquiry.create_activity :read, owner: current_user
        end
      end
    else
      @enquiry.create_activity :view, owner: current_user
    end
     @userName = @enquiry.mangerName
    
  end

  def new
    @enquiry = Enquiry.new
    @enquiry.build_address
    @enquiry.build_hire_enquiry(number_of_vehicles: 1, hire_start_date: Date.today)
    add_crumb "New"
  end

  def edit
    add_crumb @enquiry.uid, enquiry_path(@enquiry)
    add_crumb 'Edit'
    if @enquiry.enquiry_type.hire_enquiry? and @enquiry.hire_enquiry.nil?
      @enquiry.build_hire_enquiry(number_of_vehicles: 1, hire_start_date: Date.today)
    end
  end

  def create
    initialise_enquiry

    respond_to do |format|
      if @enquiry.save
        if current_user.present?
          @enquiry.create_activity :create, owner: current_user
        else
          @enquiry.create_activity :submit, owner: @enquiry.user
        end
        format.html {
          if current_user.present? && current_user.has_role?(:admin) 
            flash[:success] = "Enquiry #{@enquiry.uid} was successfully created."
            redirect_to enquiries_path
          else
            redirect_to enquiry_submitted_path(reference: @enquiry.uid)
          end
        }
        format.json { render action: 'show', status: :created, location: @enquiry }
      else
        format.html { 
          render action: 'new', layout: 'enquiry'
        }
        format.json { render json: @enquiry.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    assigned = @enquiry.manager ? @enquiry.manager : nil
    respond_to do |format|
      if @enquiry.update(new_enquiry_params)
        @enquiry.create_activity :update, owner: current_user
        if @enquiry.manager && assigned == nil
          EnquiryMailer.delay.assign_notification(@enquiry.manager.id, @enquiry.id)
          record_assign_activity
        elsif @enquiry.manager && @enquiry.manager != assigned
          EnquiryMailer.delay.assign_notification(@enquiry.manager.id, @enquiry.id)
          record_assign_activity :reassigned
        end

        format.html {
          flash[:success] = "Enquiry #{@enquiry.uid} was successfully updated."
          redirect_to action: 'show', id: @enquiry.uid, referer: "update"
        }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @enquiry.errors, status: :unprocessable_entity }
      end
    end
  end

  def assign
    authorize! :assign, Enquiry
    @enquiry.manager ? assigned = @enquiry.manager : assigned = nil
    if @enquiry.update(params.require(:enquiry).permit(:manager_id, :invoice_company_id, :seen))
      if @enquiry.manager
        EnquiryMailer.delay.assign_notification(@enquiry.manager.id, @enquiry.id)
        if assigned == nil
          record_assign_activity
          flash[:success] = "Enquiry ##{@enquiry.uid} assigned to #{@enquiry.manager.name}"
        elsif @enquiry.manager != assigned
          record_assign_activity :reassigned
          flash[:success] = "Enquiry ##{@enquiry.uid} reassigned to #{@enquiry.manager.name}"
        end
      end
      redirect_to action: 'show', id: @enquiry.uid, referer: "assign"
    else
      redirect_to request.referer
    end
  end

  def verify_customer_info
    @enquiry.update(customer_details_verified: true)
    @enquiry.create_activity :customer_details_verified, owner: current_user
    flash[:success] = "The customer details of Enquiry ##{@enquiry.uid} has been verified."
    redirect_to action: 'show', id: @enquiry.uid
  end

  def create_hire_quote
    hire_quote = hire_quote_from_enquiry
    if hire_quote.valid?
      hire_quote.save
      hire_quote.create_activity :create, owner: current_user
      @enquiry.process_notification( {event: :quote_created} )
      redirect_to controller: 'hire_quote_vehicles', action: 'new', hire_quote_id: hire_quote.reference
    else
      msg = "A Hire Quote could not be created because of these errors: "
      msg << hire_quote.errors.full_messages.join(', ')
      flash[:error] = msg
      redirect_to action: 'show', id: @enquiry.uid
    end
  end

  def destroy
    @enquiry.destroy
    respond_to do |format|
      format.html { redirect_to enquiries_url, notice: "Enquiry REF #{@enquiry.uid} deleted." }
      format.json { head :no_content }
    end
  end

  def send_enquiry_mail
    @enquiry = Enquiry.find(params[:enquiry_id])
    @message = params[:message]
    @enquiry_mails = EmailMessage.create(message: @message, uid: generate_uid)
    
    if @enquiry_mails.save

      @email_messages = EmailMessage.find(@enquiry_mails.id)
      @enquiry.email_messages << @email_messages
  
        flash_message = "Enquiry notification email sent to "
        original_length = flash_message.length
        recipient = " "
        
      if params[:send_to_service_provider] == "true"
        EnquiryMailer.notification_email(@enquiry.user.id, @enquiry.id, @message).deliver_now
        @enquiry.create_activity :send, recipient: @enquiry.user, owner: current_user
        flash_message += "#{ @enquiry.user.email}"
        recipient +=  @enquiry.user.email
      end

      if params[:send_to_service_provider] == "true" && params[:send_to_manager] == "true" 
        flash_message += " & "
        recipient += " & "
      end

      if params[:send_to_manager] == "true"
        EnquiryMailer.notification_email(@enquiry.manager.id, @enquiry.id, @message).deliver_now
        @enquiry.create_activity :send, recipient: @enquiry.manager, owner: current_user
       
        flash_message += "#{ @enquiry.manager.email}"
        recipient += @enquiry.manager.email
      end

      invalid_emails = []
      valid_emails = []
      if params[:send_to_others] == "true"
        emails = params[:send_to_others_receipients].gsub(' ', '').split(',')
        emails.each do |email|
          if email =~ /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/
            EnquiryMailer.notification_email_other_recipents(email, @enquiry.id, @message).deliver_now
            valid_emails << email
          else
            invalid_emails << email
          end
          recipient +=  email
        end
        flash_message += " & " if flash_message.length != original_length
        flash_message += valid_emails.to_sentence

      end
      success = flash_message.length != original_length
      flash_message += " with message." unless @message.blank?
      EmailMessage.where(id: @enquiry_mails.id).update_all(rerecipient: recipient )
      @email_uploads = EnquiryEmailUpload.where(:enquiry_id => @enquiry.id).where(:email_sent => true)
      @email_uploads.where( email_sent: true ).each do |e|
        e.destroy
      end
      flash[:success] = flash_message if success
      flash[:error] = "Could not send Enquiry notification to #{invalid_emails.to_sentence}." if invalid_emails.length > 0
      redirect_to(:action => 'show', :id => @enquiry.uid)
    else
      flash[:error] = "Could not send Enquiry notification email." 
      redirect_to(:action => 'show', :id => @enquiry.uid)
    end   
  end
 

  def enquiry_submitted
    @reference = params[:reference]
  end

  private
    def resolve_layout
      case action_name
      when "new"
        "enquiry"
      when "enquiry_submitted"
        "enquiry_submitted"
      else
        "application"
      end
    end

    def set_enquiry
      @enquiry = Enquiry.find_by_uid!(params[:id])
    end

    def search_params
      params.require(:enquiry_search).permit(
        :uid, :enquirer_name, :manager_name, :company_name, :enquiry_type, 
        :enquiry_status, :show_all, :sort_field, :direction, :per_page
        )
    end

    def enquiry_params
      params.require(:enquiry).permit(
        :enquiry_type_id,
        :user_id,
        :manager_id,
        :invoice_company_id,
        :uid,
        :enquiry_id,
        :first_name,
        :last_name,
        :email,
        :phone,
        :score,
        :company,
        :job_title,
        :details,
        :seen,
        :flagged,
        :status,
        :tag_list,
        :attachment,
        :find_us,
        :email_attachment,
        address_attributes: [:id, :line_1, :line_2, :suburb, :state, :postcode, :country],
        hire_enquiry_attributes: [:hire_start_date_field, :units, :duration_unit,  
              :number_of_vehicles, :minimum_seats, :delivery_required, :delivery_location, 
              :ongoing_contract, :transmission_preference, :special_requirements]
      )
    end

    def new_enquiry_params
      temp_params = enquiry_params
      if temp_params['hire_enquiry_attributes'].present?
        if temp_params['hire_enquiry_attributes']['hire_start_date_field'].empty? 
          temp_params.delete('hire_enquiry_attributes')
        end
      end  
      temp_params
    end

    def hire_quote_from_enquiry 
      hire_quote = HireQuote.new
      hire_quote.customer = @enquiry.user.client
      hire_quote.manager = @enquiry.manager.client
      hire_quote.enquiry = @enquiry
      hire_quote.authorised_contact = @enquiry.user
      hire_quote
    end

    def generate_uid
      uid = loop do
        random_id = 'EML-'  + (0...4).map{ (1..9).to_a[rand(9)] }.join
        break random_id unless EmailMessage.exists?(uid: random_id)
      end  
    end

end
