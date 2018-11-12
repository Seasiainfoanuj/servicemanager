class QuotesController < ApplicationController
  include SalesQuotesQueryFormatter
  layout :resolve_layout

  before_action :authenticate_user_from_token!, only: [:show, :request_change, :accept, :update_po]
  before_action :authenticate_user!
  load_resource :find_by => :number
  authorize_resource

  before_action :set_quote, only: [:show, :edit, :update, :update_po, :destroy]

  add_crumb("Quotes") { |instance| instance.send :quotes_path }

  def index
    session['last_request'] = '/quotes'
    @filtered_user = User.find(params[:filtered_user_id]) if params[:filtered_user_id]
    if @filtered_user
      add_crumb "Users", users_path
      add_crumb @filtered_user.name, user_path(@filtered_user)
      add_crumb('Quotes') { |instance| instance.send :quotes_path }
    end

    @search = get_search_details
    session[:sales_quotes_search] = @search
    @quote_tags = get_quote_tags

    if params[:user_id].present?
      quotes = get_quotes_users(params[:user_id])
    else  
      unless current_user.has_role? :dealer
        quotes = get_quotes
      else
        quotes = get_quotes_dealer
      end 
    end

       
    @quotes = quotes.paginate(page: params[:page], per_page: @search.per_page.to_i).order(ordering)
  end

  def search
    @filtered_user = User.find(params[:filtered_user_id]) if params[:filtered_user_id]
    if @filtered_user
      add_crumb "Users", users_path
      add_crumb @filtered_user.name, user_path(@filtered_user)
      add_crumb('Search Quotes') { |instance| instance.send :quotes_path }
    end

    @search = get_search_details
    session[:sales_quotes_search] = @search
    @quote_tags = get_quote_tags
    quotes = get_quotes
    @quotes = quotes.paginate(page: params[:page], per_page: @search.per_page.to_i).order(ordering)
    render 'index'
  end

  def show
    if (@quote.status == 'draft') && !current_user.admin?
      flash[:error] = "Unauthorised access"
      redirect_to(action: 'index') and return
    end
    @activities = PublicActivity::Activity.order("created_at desc").where(:trackable_type => "Quote", :trackable_id => @quote.id)
    if current_user == @quote.customer
      unless params[:referrer] == "accepted" ||  params[:referrer] == "request_change" || params[:referrer] == "po_submitted"
        @quote.create_activity :view, owner: current_user
      end
      unless @quote.status == "accepted" || @quote.status == "changes requested" || @quote.status == "cancelled"
        @quote.update(:status => "viewed")
      end
    end

    set_item_visibility

    respond_to do |format|
      format.html { add_crumb @quote.number }
      format.pdf do
        pdf = QuotePdf.new(@quote, @hide_all_cost_columns, view_context)
        send_data pdf.render, filename: "quote_#{@quote.number}.pdf",
                              type: "application/pdf",
                              disposition: "inline"
      end
    end
  end

  def create_contract
    authorize! :create, VehicleContract
    @quote = Quote.find_by(number: params[:quote_id])
    if @quote.nil?
      flash[:error] = "Quote number not found."
      redirect_to(action: 'index') and return
    end
    if @quote.vehicle_contract.present?
      redirect_to(:controller => 'vehicle_contracts', :action => 'show', :id => @quote.vehicle_contract.id) and return
    end
    unless QuoteStatus.action_permitted?(:create_contract, @quote.status)
      flash[:error] = "A quote with a status of #{@quote.status} can not be converted to a contract."
      redirect_to(:action => 'show', :id => @quote.number) and return
    end   
    redirect_to(:controller => 'vehicle_contracts', :action => 'new', :quote_number => @quote.number)
  end

  def new
    @quote = Quote.new
    @quote.number = Quote.where.not(amendment: true).last.number.next if Quote.last
    @quote.date = Time.now.strftime("%d/%m/%Y") unless @quote.date
    3.times { @quote.items.build }
    add_crumb "New"
  end

  def create
    @quote = Quote.new(quote_params_modified)
    @quote.status = "draft"
    if @quote.save
      @quote.create_activity :create, owner: current_user
      @quote.customer.update_roles( {event: :quote_created} )
      if params[:enquiry].present?
          @enquiry = Enquiry.find(params[:enquiry])
          @quote.enquiry << @enquiry
      end
      flash[:success] = "Quote created."
      redirect_to(:action => 'show', :id => @quote.number)
    else
      error_msg = ""
      @quote.errors.full_messages.each { |e| error_msg << "#{e}. " }
      flash[:error] = "#{error_msg}"
      render 'new'
    end
  rescue ArgumentError => e
    flash[:error] = e.message
    render('new')
  end

  def create_from_master
    authorize! :create_from_master, Quote
    if params[:master_quote_id] && params[:customer_id]
      master_quote, quote = new_quote_from_master_quote

      if quote.save
        if master_quote.title_page
          quote.create_title_page(
            title: master_quote.title_page.title,
            image_1: master_quote.title_page.image_1,
            image_2: master_quote.title_page.image_2
          )
        end
        if master_quote.summary_page
          quote.create_summary_page(
            text: master_quote.summary_page.text
          )
        end
        quote.copy_attachments_from_master(master_quote)
        quote.copy_specification_sheet_from_master(master_quote)
        enquiry = get_matching_enquiry(params[:customer_id])
        enquiry.process_notification( {event: :quote_created} ) if enquiry.present?
        quote.customer.update_roles( {event: :quote_created} )

        quote.create_activity :create_from_master, owner: current_user, parameters: {master_quote_name: master_quote.name}

        flash[:success] = "Quote created from master quote #{master_quote.name}."
        redirect_to edit_quote_path(quote)
      else
        flash[:error] = "There was a problem creating a quote from master quote: #{master_quote.name}."
        redirect_to master_quote
      end
    else
      flash[:error] = "Some details are missing. Please try again."
      redirect_to request.referer
    end
  end

  def duplicate
    authorize! :duplicate, Quote
    @old_quote = Quote.find(params[:quote_id])
    @duplicate_actions = []
    @quote = new_quote_from_duplicated_quote
    @duplicate_actions << "Quote #{@quote.number} created without associations"
    duplicate_quote_items
    duplicate_tag_lists
    duplicate_title_page
    duplicate_cover_letter
    duplicate_attachments
    
    @quote.create_activity :duplicate, owner: current_user
    @duplicate_actions << "Activity created for duplication"
    @quote.save!
    flash[:success] = "Quote #{@old_quote.number} duplicated. The new quote number is #{@quote.number}"
    redirect_to edit_quote_path(@quote) and return
  rescue
    flash[:error] = "An error occurred creating a new quote, based on quote #{@old_quote.number}."
    error_msgs = @duplicate_actions
    error_msgs << "Duplication of Quote #{@quote.number} could not be completed"
    @quote.errors.full_messages.each { |e| error_msgs << "#{e}. " }
    SystemError.create!(resource_type: SystemError::QUOTE, error_status: SystemError::ACTION_REQUIRED, description: error_msgs.join("\n"))
    redirect_to @old_quote and return
  end

  def create_amendment
    authorize! :create_amendment, Quote
    @old_quote = Quote.find(params[:quote_id])

    @amendment_quote = @old_quote.dup

    if @old_quote.amendment?
      @amendment_quote.number = @old_quote.number.next
    else
      @amendment_quote.number = "#{@old_quote.number}-1"
    end

    @amendment_quote.amendment = true
    @amendment_quote.status = "draft"
    @amendment_quote.date = Time.now.strftime("%d/%m/%Y")

    @old_quote.items.each do |item|
      dup_item = item.dup
      dup_item.quote = @amendment_quote
      @amendment_quote.items << dup_item
    end

    @old_quote.tag_list.each do |tag|
      dup_tag = tag.dup
      @amendment_quote.tag_list << dup_tag
    end

    if @amendment_quote.save && @old_quote.update(status: 'cancelled')
      if @old_quote.title_page
        QuoteTitlePage.create(
          quote: @amendment_quote,
          title: @old_quote.title_page.title,
          image_1: @old_quote.title_page.image_1,
          image_2: @old_quote.title_page.image_2
        )
      end

      if @old_quote.cover_letter
        QuoteCoverLetter.create(
          quote: @amendment_quote,
          title: @old_quote.cover_letter.title,
          text: @old_quote.cover_letter.text
        )
      end

      unless @old_quote.attachments.empty?
        @old_quote.attachments.each do |file|
          QuoteUpload.create(
            quote: @amendment_quote,
            upload: file.upload
          )
        end
      end

      @old_quote.create_activity :cancel, owner: current_user
      @amendment_quote.create_activity :amended, owner: current_user

      flash[:success] = "Quote #{@old_quote.number} cancelled and amendment created. Continue editing below."
      redirect_to edit_quote_path(@amendment_quote)
    else
      flash[:error] = "There was a problem amending quote #{@old_quote.number}."
      redirect_to @old_quote
    end
  end

  def edit
    add_crumb @quote.number, quote_path(@quote)
    add_crumb 'Edit'
  end

  def update_po
    authorize! :update_po, Quote
    if @quote.update(params.require(:quote).permit(:po_number,:po_upload))
      @quote.create_activity :update_po, owner: current_user

      if @quote.po_number.blank? && @quote.po_upload.blank?
        flash[:error] = "Nothing was submitted. Please try again."
      else
        flash[:success] = "Thank you, Your purchase order has been submitted."
      end

      redirect_to(:action => 'show', :id => @quote.number, :user_email => params[:user_email], :user_token => params[:user_token], :referrer => "po_submitted")
    else
      flash[:error] = "Purchase Order Upload was unsuccessful. You may consider uploading a PDF file if your file has a different format."
      redirect_to(:action => 'show')
    end
  end

  def update
    unless QuoteStatus.action_permitted?(:update, @quote.status)
      flash[:error] = "A quote with a status of #{@quote.status} may not be updated."
      redirect_to(:action => 'show', :id => @quote.number) and return
    end   
    @quote_status = derive_status_from_params
    @quote.attributes = quote_params
    
    check_for_changes(@quote) # returns @change_notes

    if @quote.update_attributes(quote_params_modified)
      @quote.create_activity :update, owner: current_user

      create_change_notes(@quote, @change_notes)  # @change_notes is often blank !!!!

      flash[:success] = "Quote updated."
      redirect_to(:action => 'show')
    else
      flash[:error] = "Quote update failed!"
      write_update_params_in_logger
      render('edit')
    end
  rescue ArgumentError => e
    flash[:error] = e.message
    render('edit')
  end

  def send_quote
    authorize! :send_quote, Quote
    @quote = Quote.find(params[:quote_id])
    unless QuoteStatus.action_permitted?(:send_quote, @quote.status)
      flash[:error] = "A quote with a status of #{@quote.status} may not be sent."
      redirect_to(:action => 'show', :id => @quote.number) and return
    end
    @quote.status = QuoteStatus.status_after_action(:send_quote, @quote.status)
    @quote.save
    @quote.customer.update_roles( {event: :quote_sent} )
    @quote.customer.addRole()
    @message = params[:message]
    @quote.create_activity :send, recipient: @quote.customer, owner: current_user
    QuoteMailer.quote_email(@quote.customer.id, @quote.id, @message).deliver_now
    flash[:success] = "Quote sent to #{@quote.customer.email}"
    redirect_to(:action => 'show', :id => @quote.number)
  end

  def request_change
    authorize! :request_change, Quote
    @quote = Quote.find_by_number!(params[:quote_id])
    unless QuoteStatus.action_permitted?(:request_change, @quote.status)
      flash[:error] = "Changes are not permitted on a quote with a status of #{@quote.status}."
      redirect_to(:action => 'show', :id => @quote.number) and return
    end
    @customer = @quote.customer
    @customer.first_name = params[:first_name] if params[:first_name]
    @customer.last_name = params[:last_name] if params[:last_name]
    @customer.mobile = params[:mobile] if params[:mobile]
    @customer.save

    @quote.status = QuoteStatus.status_after_action(:request_change, @quote.status)
    @message = params[:message]

    if @quote.save
      QuoteMailer.delay.request_changes_email(@quote.id, @message)
      @quote.create_activity :request_change, owner: current_user
      flash[:success] = "Changes have been requested. We will be in touch with you shortly. Thank you."
      redirect_to(:action => 'show', :id => @quote.number, :user_email => params[:user_email], :user_token => params[:user_token], :referrer => "request_change")
    end
  end

  def accept
    authorize! :accept, Quote
    @quote = Quote.find_by_number!(params[:quote_id])
    unless QuoteStatus.action_permitted?(:accept, @quote.status)
      flash[:error] = "A quote with a status of #{@quote.status} may not be accepted."
      redirect_to(:action => 'show', :id => @quote.number) and return
    end
    @quote.status = QuoteStatus.status_after_action(:accept, @quote.status)
    if @quote.save
      @quote.manager ? manager_id = @quote.manager.id : manager_id = nil
      QuoteMailer.delay.accept_notification_email(manager_id, @quote.id)

      if @quote.invoice_company.accounts_admin
        QuoteMailer.delay.accept_notification_email(@quote.invoice_company.accounts_admin.id, @quote.id) if @quote.invoice_company.accounts_admin
      end

      @quote.create_activity :accept, owner: current_user

      flash[:success] = "Quote accepted."
      redirect_to(:action => 'show', :id => @quote.number, :user_email => params[:user_email], :user_token => params[:user_token], :referrer => "accepted")
    end
  end

  def cancel
    authorize! :cancel, Quote
    @quote = Quote.find_by_number!(params[:quote_id])
    unless QuoteStatus.action_permitted?(:cancel, @quote.status)
      flash[:error] = "A quote with a status of #{@quote.status} may not be cancelled."
      redirect_to(:action => 'show', :id => @quote.number) and return
    end
    @quote.update(status: 'cancelled')
    @quote.create_activity :cancel, owner: current_user

    flash[:success] = "Quote #{@quote.number} cancelled."
    redirect_to(:action => 'index')
  end

  def destroy
    unless QuoteStatus.action_permitted?(:destroy, @quote.status)
      flash[:error] = "A quote with a status of #{@quote.status} may not be deleted."
      redirect_to(:action => 'show', :id => @quote.number) and return
    end
    @quote.destroy
    flash[:success] = "Quote deleted."
    redirect_to(:action => 'index')
  end

  private

    def authenticate_user_from_token!
      user_email = params[:user_email].presence
      user       = user_email && User.find_by_email(user_email)
      if params[:id].presence
        quote_id   = params[:id]
      elsif params[:quote_id].presence
        quote_id   = params[:quote_id]
      end
      quote      = quote_id && user_email && User.find_by_email(user_email).quotes.find_by_number(quote_id)
      if user && quote && Devise.secure_compare(user.authentication_token, params[:user_token])
        sign_in user, store: false
      end
    end

    def resolve_layout
      case action_name
      when "show"
        "clean"
      else
        "application"
      end
    end

    def set_quote
      @quote = Quote.find_by_number!(params[:id])
    end

    def quote_params_modified
      @new_params = temp_params = quote_params
      @item_type_rules = {}
      QuoteItemType.all.map { |type| @item_type_rules[type.id.to_s] = [type.sort_order, type.taxable] }
      @no_tax_id =  Tax.where('id = 1')
      if temp_params['items_attributes'].present?
        temp_params['items_attributes'].each do |key, val|
          update_params(key, val)
        end
      end
      @new_params
    end

    def search_params
      params.require(:quote_search).permit(
        :quote_number, :customer_name, :manager_name, :company_name, :quote_status,
        :show_all, :sort_field, :direction, :per_page, :tag_ids => []
        )
    end

    def quote_params
      params.require(:quote).permit(
        :invoice_company_id,
        :customer_id,
        :manager_id,
        :number,
        :po_number,
        :po_upload,
        :delete_po_upload,
        :date_field,
        :discount,
        :status,
        :terms,
        :user_id,
        :enquiry,
        :comments,
        :tag_list,
        items_attributes: [:id, :quote_id, :supplier_id, :service_provider_id, :name,
          :description, :cost, :tax_id, :buy_price, :buy_price_tax_id, :quantity,
          :position, :quote_item_type_id, :hide_cost, :_destroy
        ]
      )
    end

    def new_quote_from_master_quote
      customer_id, master_quote_id = params[:customer_id], params[:master_quote_id]
      quote = Quote.new
      quote.number = Quote.where.not(amendment: true).last.number.next if Quote.last
      quote.date = Time.now.strftime("%d/%m/%Y")
      quote.status = "draft"
      quote.invoice_company = InvoiceCompany.first
      quote.manager = current_user
      quote.customer_id = customer_id

      master_quote = MasterQuote.find(params[:master_quote_id])
      quote.master_quote = master_quote
      quote.terms = master_quote.terms
      quote.comments = master_quote.notes

      quote.tag_list.add(master_quote.vehicle_make) if master_quote.vehicle_make.present?
      quote.tag_list.add(master_quote.vehicle_model) if master_quote.vehicle_model.present?
      quote.tag_list.add(master_quote.name) if master_quote.name.present?
      quote.tag_list.add(master_quote.type.name) if master_quote.type.present? && master_quote.type.name.present?
      quote.tag_list.add(master_quote.transmission_type) if master_quote.transmission_type.present?

      master_quote.items.each do |item|
        quote.items.build(
          quote_item_type_id: item.quote_item_type_id,
          master_quote_item_id: item.id, 
          name: item.name,
          description: item.description,
          supplier_id: item.supplier_id,
          service_provider_id: item.service_provider_id,
          cost: item.cost,
          hide_cost: true,
          tax_id: item.cost_tax_id,
          buy_price: item.buy_price,
          buy_price_tax_id: item.buy_price_tax_id,
          quantity: item.quantity,
        )
      end
      [master_quote, quote]
    end

    def new_quote_from_duplicated_quote
      @quote = Quote.new
      @quote.customer_id = @old_quote.customer_id
      @quote.manager_id = @old_quote.manager_id
      @quote.number = Quote.where.not(amendment: true).last.number.next
      @quote.date = Time.now.strftime("%d/%m/%Y")
      @quote.discount = @old_quote.discount
      @quote.status = "draft"
      @quote.terms = @old_quote.terms
      @quote.comments = @old_quote.comments
      @quote.invoice_company_id = @old_quote.invoice_company_id
      @quote.amendment = false
      @quote.save!
      @quote
    end

    def duplicate_quote_items
      @old_quote.items.each do |item|
        dup_item = item.dup
        dup_item.name = dup_item.description[0..10] if dup_item.name == ""
        dup_item.quote = @quote
        @quote.items << dup_item
      end
      @duplicate_actions << "Item copied from old to new quote"
    end

    def duplicate_tag_lists
      @old_quote.tag_list.each do |tag|
        dup_tag = tag.dup
        @quote.tag_list << dup_tag
      end
      @duplicate_actions << "Taglists copied from old to new quote"
    end

    def duplicate_title_page
      if @old_quote.title_page
        title_page = QuoteTitlePage.new(
          quote: @quote,
          title: @old_quote.title_page.title,
          image_1: @old_quote.title_page.image_1,
          image_2: @old_quote.title_page.image_2
        )
        if title_page.valid?
          title_page.save
          @duplicate_actions << "Title page created"
        else
          @duplicate_actions << "Title page cannot be created"
          @duplicate_actions << title_page.errors.full_messages.first
        end
      end
    end

    def duplicate_cover_letter
      if @old_quote.cover_letter
        QuoteCoverLetter.create(
          quote: @quote,
          title: @old_quote.cover_letter.title,
          text: @old_quote.cover_letter.text
        )
        @duplicate_actions << "QuoteCoverLetter created"
      end
    end

    def duplicate_attachments
      @old_quote.attachments.each do |file|
        attachment = QuoteUpload.new(
          quote: @quote,
          upload: file.upload
        )
        attachment.save if attachment.valid?
      end
      @duplicate_actions << "Attachments saved"
    end

    def get_matching_enquiry(customer_id)
      return nil unless session[:current_enquiry].present?
      enquiry = Enquiry.find_by(id: session[:current_enquiry])
      return nil unless enquiry and !enquiry.quoted?
      customer_id.to_i == enquiry.user_id ? enquiry : nil  
    end 

    def derive_status_from_params
      if params[:save_draft]
        "draft"
      elsif params[:update_draft]
        "updated"
      else
        @quote.status
      end
    end
    
    def update_params(key, val)
      name = val["name"]
      description = val["description"]
      quantity = val["quantity"]
      quote_item_type_id = val["quote_item_type_id"].to_s
      hide_cost = val["hide_cost"].present? ? val["hide_cost"] : "false"
      if name.empty? && description.empty?
        @new_params['items_attributes'][key]["_destroy"] = "true"
        return
      end
      cost = val["cost"].to_f
      if description.empty?
        @new_params['items_attributes'][key]["description"] = name
      elsif name.empty?
        @new_params['items_attributes'][key]["name"] = description[0..10]
      end
      @new_params['items_attributes'][key]["quantity"] = "1" if quantity == 0
      unless quote_item_type_id.present?
        quote_item_type_id = QuoteItemType.find_by(name: "Other").id
        @new_params['items_attributes'][key]["quote_item_type_id"] = quote_item_type_id.to_s
      end
      @new_params['items_attributes'][key]["hide_cost"] = hide_cost
      @new_params['items_attributes'][key]["primary_order"] = @item_type_rules[quote_item_type_id.to_s][0]
      if @item_type_rules[quote_item_type_id.to_s][1] == QuoteItemType::ALWAYS_TAXED && 
          @new_params['items_attributes'][key]["tax_id"] == @no_tax_id
        raise ArgumentError, "No Tax option specified for taxed item, #{name}"
      end
      if @item_type_rules[quote_item_type_id.to_s][1] == QuoteItemType::NOT_TAXED && 
          @new_params['items_attributes'][key]["tax_id"] != @no_tax_id
        raise ArgumentError, "GST specified for non-taxed item, #{name}"
      end  
    end

    def make_all_items_visible
      @quote.items.each do |item|
        item.assign_attributes(hide_cost: false)
      end
    end

    def set_item_visibility
      @hide_all_cost_columns = @quote.all_items_hidden?
      if params[:show_costs] == "true" && current_user.has_role?(:admin) 
        make_all_items_visible
        @hide_all_cost_columns = false
      end
    end

    def check_for_changes(quote)
      notes = ""
      change_icon = ">>"
      if quote.changed?
        notes += "QUOTE UPDATES:\n"
        column_names = ["po_upload_content_type", "po_upload_file_size", "po_upload_updated_at", "customer_id"]
        quote.changes.each do |column, changes|
          unless column_names.include?(column)
            notes +=  "- "
            case column
            when "invoice_company_id"
              notes += invoice_company_changes(changes)
            when "manager_id"
              notes += manager_changes(changes)
            when "po_upload_file_name"
              notes += po_upload_file_name_changes(changes)
            when "total_cents"
              notes += total_cents_changes(changes)
            else
              if changes[0].blank? && changes[1].present?
                notes += "#{column.humanize} added: #{changes[1]}\n"
              elsif changes[0].present? && changes[1].blank?
                notes += "Removed #{column.humanize}: #{changes[0]}\n"
              else
                notes += "#{column.humanize} changed: #{changes[0]} #{change_icon} #{changes[1]}\n"
              end
            end
          end
        end
      end

      quote.items.each do |item|
        if item._destroy == true
          notes += "\nLine item removed:\n"
          notes += "- Item Type: #{item.item_type_name}\n"
          notes += "- Name: #{item.name}\n"
          notes += "- Description: #{item.description}\n" if item.description.present?
          notes += "- Cost: $#{item.cost_cents/100}\n" if item.cost_cents.present?
          notes += "- Qty: #{item.quantity}\n" if item.quantity.present?
          notes += "- Tax: #{item.tax.name}\n" if item.tax
        end
        change_icon = ">>"
        if item.changed?
          if item.name.present?
            notes += "\n#{item.name}:\n"
          else
            notes += "\nLine item updated:\n"
          end
          col_names = ["quote_id", "supplier_id", "service_provider_id", "buy_price_cents", "buy_price_tax_id", "updated_at", "position", "quote_item_type_id"]
          item.changes.each do |column, changes|
            unless col_names.include?(column)
              notes += "- "
              case column
              when "name"
                if changes[0].blank? && changes[1].present?
                  notes += "Line item added\n"
                elsif changes[0].present? && changes[1].blank?
                  notes += "Name removed: #{changes[0]}\n"
                else
                  notes += "Name changed: #{changes[0]} #{change_icon} #{changes[1]}\n"
                end
              when "tax_id"
                t1 = Tax.find(changes[0]) if changes[0].present?
                t2 = Tax.find(changes[1]) if changes[1].present?
                if t1 && t2
                  notes += "Tax changed: #{t1.name} #{change_icon} #{t2.name}\n"
                end
              when "cost_cents"
                c1_cents = changes[0].to_f
                c2_cents = changes[1].to_f

                if c2_cents > c1_cents
                  cost_change_cents = c2_cents - c1_cents
                  p = "+"
                else
                  cost_change_cents = c1_cents - c2_cents
                  p = "-"
                end
                notes += "Item cost adjusted #{p}$#{cost_change_cents/100}\n"
              when "hide_cost"
              	puts "changes"
              	puts "#{changes[1]}"
                if changes[1] == true
                  notes += "Price information hidden\n"
                else
                  notes += "Price information displayed\n"
                end
              else
                if changes[0].blank? && changes[1].present?
                  notes += "#{column.humanize} added: #{changes[1]}\n"
                elsif changes[0].present? && changes[1].blank?
                  notes += "Removed #{column.humanize}: #{changes[0]}\n"
                else
                  notes += "#{column.humanize} changed: #{changes[0]} #{change_icon} #{changes[1]}\n"
                end
              end
            end
          end
          notes += "\n"
        end
      end
       @change_notes = notes
    end

    def invoice_company_changes(changes)
      change_icon = ">>"
      c1 = InvoiceCompany.find(changes[0]) if changes[0].present?
      c2 = InvoiceCompany.find(changes[1]) if changes[1].present?
      if c1 && c2
        return "Quote company changed: #{c1.name} #{change_icon} #{c2.name}\n"
      else
        return "Quote company changed\n"
      end
    end

    def manager_changes(changes)
      change_icon = ">>"
      u1 = User.find(changes[0]) if changes[0].present?
      u2 = User.find(changes[1]) if changes[1].present?
      if u1 && u2
        return "Manager changed: #{u1.name} #{change_icon} #{u2.name}\n"
      else
        return "Manager changed\n"
      end
    end

    def po_upload_file_name_changes(changes)
      if changes[0].blank? && changes[1].present?
        return "PO attachment added\n"
      elsif changes[0].present? && changes[1].blank?
        return "PO attachment removed\n"
      end
    end

    def total_cents_changes(changes)
      change_icon = ">>"
      c1_cents = changes[0].to_f
      c2_cents = changes[1].to_f
      if c2_cents > c1_cents
        total_change_cents = c2_cents - c1_cents
        p = "+"
      else
        total_change_cents = c1_cents - c2_cents
        p = "-"
      end
      "Quote total adjusted #{p}$#{total_change_cents/100} ($#{c1_cents/100} #{change_icon} $#{c2_cents/100})\n"
    end

    def create_change_notes(quote, change_notes)
      if change_notes.present?
        quote.notes.create(
          comments: change_notes,
          author: current_user,
          public: false
        )
      end
    end

    def write_update_params_in_logger
      Rails.logger.warn "Quote Update was unsuccessful"
      Rails.logger.warn "Quote: #{@quote.inspect}"
      if @quote.items.any?
        @quote.items.each do |item|
          Rails.logger.warn "Quote Item: #{item.inspect}"
        end
      end
      Rails.logger.warn "Quote params: #{quote_params}"
      Rails.logger.warn "Quote attributes: #{@quote.attributes.inspect}"
    end

    def get_quote_tags
      quote_taggings = ActsAsTaggableOn::Tagging.includes(:tag).where(taggable_type: 'Quote')
      tagging_tags = quote_taggings.collect { |tagging| tagging.tag }
      tagging_tags.uniq.sort
    end  

end
