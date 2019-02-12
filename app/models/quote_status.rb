class QuoteStatus

  VALID_STATUSSES = ['draft', 'updated', 'changes requested', 'sent', 'resent', 
                     'viewed', 'accepted', 'cancelled', 'rejected']
  DISPLAY_STATUSSES = ['Draft', 'Updated', 'Changes Requested', 'Sent', 'Resent',
                     'Viewed', 'Accepted', 'Cancelled', 'Rejected']
  VALID_ACTIONS = [:show, :update, :send_quote, :request_change, :accept, :cancel, 
                   :create_contract, :destroy, :create_amendment]

  def self.status_after_action(action, current_status)
    validate_action(action)
    validate_status(current_status)
    case action
    when :send_quote
      if current_status == 'accepted'
        current_status
      else
        current_status == "sent" ? "resent" : "sent"
      end
    when :show
      if ['draft', 'updated', 'sent', 'resent', 'viewed'].include?(current_status)
        'viewed'
      else
        current_status
      end
    when :cancel
      'cancelled'
    when :accept
      'accepted'
    when :request_change
      'changes requested'
    else
      raise "Action Invalid"
    end
  end

  def self.action_permitted?(action, current_status = nil)
    validate_action(action)
    validate_status(current_status) unless current_status.nil?

    case action
    when :update
      ["accepted", "cancelled"].exclude?(current_status)
    when :request_change
      true
    when :send_quote
      true
    when :accept
      ["accepted", "verified", "signed"].exclude?(current_status)
      # an amendment can cancel the quote
    when :cancel 
      ["accepted", "cancelled", "verified", "signed"].exclude?(current_status)
    when :sign_contract
      current_status == "verified"
    when :destroy
      ["draft", "updated", "sent", "resent", "viewed"].include?(current_status)
    when :create_amendment
      current_status == "accepted"  
    when :create_contract
      current_status == "accepted"  
    else
      raise "Unexpected Action"
    end
  end

  def self.display_status(status)
    inx = VALID_STATUSSES.index(status)
    DISPLAY_STATUSSES[inx]
  end

  def self.send_or_resend(status)
    if ["sent", "viewed", "changes requested", "accepted", "verified"].include?(status)
      'resend'
    else
      'send'
    end
  end

  def self.statuses_before_acceptance
    ['draft', 'updated', 'changes requested', 'sent', 'resent', 'viewed']
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
      VALID_STATUSSES.include?(status)
    end
      
    def self.valid_action?(action)
      VALID_ACTIONS.include?(action)
    end
end