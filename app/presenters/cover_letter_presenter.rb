class CoverLetterPresenter < BasePresenter
  delegate :link_to, to: :@view

  def initialize(model, view)
    super
    @cover_letter = model
    @subject = model.covering_subject
  end

  def content
    @cover_letter.content || default_content
  end

  def default_content
    letter_text = "Dear #{subject_customer.name},\n\n"
    letter_text += "[..]"
    letter_text += "\n\nBest Regards,\n\n"
    letter_text += subject_manager_address_info if subject_manager
  end

  def subject_customer
    if @subject.is_a? HireQuote
      @subject.authorised_contact
    end
  end

  def subject_manager
    if @subject.is_a? HireQuote
      @subject.manager.user
    elsif @subject.is_a? Quote
      @subject.manager      
    end
  end

  def quoting_company
    if @subject.is_a? HireQuote
      @subject.quoting_company
    elsif @subject.is_a? Quote      
      @subject.internal_company
    end
  end

  def subject_manager_address_info
    manager = subject_manager
    address_info = []
    address_info << manager.name
    address_info << manager.job_title
    address_info << quoting_company.name
    address_info << subject_manager_postal_address
    address_info.select { |line| line.present? }.join("\n")
  end

  def subject_manager_postal_address
    return unless subject_manager.postal_address
    address = subject_manager.postal_address
    address_lines = []
    address_lines << address.line_1
    address_lines << address.line_2
    address_lines << address.suburb
    address_lines << address.state
    address_lines << address.postcode
    address_lines.select { |line| line.present? }.join("\n")
  end
end