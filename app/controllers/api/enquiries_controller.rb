class Api::EnquiriesController < ApplicationController
  include EnquiryActions
  skip_before_filter :verify_authenticity_token, :only => :create

  def enquiry_types
    @enquiry_types = EnquiryType.all
  end

  def show
  end

  def create
    begin
      initialise_enquiry
      if @enquiry.hire_enquiry && @enquiry.hire_enquiry.hire_start_date.blank?
        @enquiry.hire_enquiry.delete
      end
      if enquiry_is_valid?
        @enquiry.save
        @enquiry.user.update_roles( {event: :enquiry_created} )
        @enquiry.create_activity :submit, owner: @enquiry.user
        render action: 'show', status: :created, location: @enquiry
      else
        errors = @enquiry.errors.any? ? @enquiry.errors : []
        errors = @enquiry.hire_enquiry.errors if errors.none?
        render json: errors, status: :unprocessable_entity
      end
    rescue Exception => e
      render json: { errors: [e.message] }, status: :unprocessable_entity
    end
  end

  private

    def enquiry_is_valid?
      return false unless @enquiry.valid?
      return true unless @enquiry.hire_enquiry
      @enquiry.hire_enquiry.valid?
    end

    def enquiry_params
      params.require(:enquiry).permit(
        :enquiry_type_id,
        :first_name,
        :last_name,
        :email,
        :phone,
        :company,
        :job_title,
        :details,
        :find_us,
        :subscribe_to_newsletter
        )
    end

    def hire_enquiry_params
      params.permit(
        :number_of_vehicles,
        :hire_start_date,
        :units,
        :duration_unit,
        :minimum_seats,
        :ongoing_contract,
        :delivery_required,
        :delivery_location,
        :transmission_preference,
        :special_requirements
        )
    end

    def enquiry_params_new
      temp_params = {}
      new_params = {}
      new_params = enquiry_params
      if hire_enquiry_params.present? and hire_enquiry_params[:units].present? and hire_enquiry_params[:hire_start_date].present?
        new_params[:hire_enquiry_attributes] = hire_enquiry_params
        new_params[:hire_enquiry_attributes][:number_of_vehicles] = hire_enquiry_params[:number_of_vehicles].to_i
        new_params[:hire_enquiry_attributes][:units] = hire_enquiry_params[:units].to_i
        new_params[:hire_enquiry_attributes][:minimum_seats] = hire_enquiry_params[:minimum_seats].to_i
        unless HireEnquiry::TRANSMISSION_PREFERENCES.include?(new_params[:hire_enquiry_attributes][:transmission_preference])
          new_params[:hire_enquiry_attributes][:transmission_preference] = "No Preference"
        end
      end
      new_params
    end

    def source_application
      if params['source_application'].present?
        if params['source_application'] == 'cms'
          return Enquiry::CMS
        elsif params['source_application'] == 'i-bus'
          return Enquiry::IBUS
        end  
      else
        return Enquiry::SERVICE_MANAGER
      end
    end

    def initialise_enquiry
      @enquiry = Enquiry.new(enquiry_params_new)
      @enquiry.enquiry_type = EnquiryType.first unless @enquiry.enquiry_type.present?
      return unless @enquiry.valid?

      @enquiry.seen = false
      @enquiry.status = 'new'
      @enquiry.score = 'cold'
      @enquiry.origin = source_application
      @enquiry.user = user_from_enquiry
      assign_enquiry_company_to_user

      if @enquiry.hire_enquiry && @enquiry.hire_enquiry.hire_start_date
        if @enquiry.hire_enquiry.special_requirements && @enquiry.hire_enquiry.special_requirements.length > 255
          @enquiry.hire_enquiry.special_requirements = @enquiry.hire_enquiry.special_requirements[0..254] 
        end
        @enquiry.enquiry_type = EnquiryType.hire_enquiry
        @enquiry.invoice_company = InvoiceCompany.hire_company
      end  
    end

end
