class QuotePdf
  class SummaryPage
    def initialize(quote)
      @summary_page = quote.summary_page.try(:text)
    end

    def render
      return unless summary_page
      ::WickedPdf.new.pdf_from_string(summary_page_decorated, margin: { top: 20, bottom: 20, left: 20, right: 20 })
    end

    private

    attr_reader :summary_page

    def summary_page_decorated
      '<div style="font-family: Helvetica; font-size: 12px; line-height: 1.2em;">' + summary_page + '</div>'
    end
  end
end
