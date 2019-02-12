class VehicleContractStatusManager

  VALID_STATUSES = ['draft', 'verified', 'presented_to_customer', 'signed', 'declined']
  VALID_ACTIONS = [:show, :create, :update, :verify_customer_info, :send_contract, :view_customer_contract, :review, :accept, :upload_contract]

  def self.status_after_action(action)
    validate_action(action)
    case action
    when :create
      'draft'
    when :verify_customer_info
      'verified'
    when :send_contract
      'presented_to_customer'
    when :upload_contract
      'presented_to_customer'
    when :review
      'presented_to_customer'
    when :accept
      'signed'
    end
  end

  def self.action_permitted?(action, options = {} )
    validate_action(action)
    current_status = options[:current_status]
    current_user = options[:current_user]
    validate_status(current_status) unless current_status.blank?

    case action
    when :update
      ["presented_to_customer", "signed", nil].exclude?(current_status)
    when :verify_customer_info
      current_status == "draft"
    when :send_contract
      ["verified", "presented_to_customer"].include?(current_status)
    when :review
      current_status == "presented_to_customer"
    when :accept
      current_status == 'presented_to_customer'
    when :upload_contract
      signed_contract_exists = options[:signed_contract_exists]
      return false unless ["presented_to_customer", "signed"].include?(current_status)
      return true if current_status == "presented_to_customer"
      return true unless signed_contract_exists
      current_user.admin?
    when :view_customer_contract
      return false unless current_user
      user = current_user
      return true if user.admin?
      ['presented_to_customer', 'signed'].include?(current_status)
    end
  end

  private

    def self.validate_action(action)
      raise "Invalid Action Format" unless action.is_a?(Symbol)
      raise "Invalid Action" unless valid_action?(action)
    end

    def self.validate_status(status)
      raise "Invalid Status Format" unless status.is_a?(String)
      raise "Invalid Status" unless valid_status?(status)
    end

    def self.valid_status?(status)
      VALID_STATUSES.include?(status)
    end
      
    def self.valid_action?(action)
      VALID_ACTIONS.include?(action)
    end
end