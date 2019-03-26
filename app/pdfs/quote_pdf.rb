class QuotePdf
  def initialize(quote, hide_all_cost_columns, view)
    @pdf = CombinePDF.new
    @quote = quote

    @title_pages_src = TitlePages.new(quote) if quote.title_page.present? || quote.cover_letter.present?
    @summary_page_src = SummaryPage.new(quote) if quote.summary_page
    @quote_page_src = QuotePage.new(quote, hide_all_cost_columns, view)
    @images_page_src = ImagesPage.new(quote) if quote.attachments.present?
  end

  def render
    assemble
    number_pages
    pdf.to_pdf
  end

  private

  attr_accessor :pdf, :quote, :title_pages_src, :quote_page_src, :images_page_src, :summary_page_src

  # Maintain section order here
  def assemble
    title_pages
    summary_page
    quote_page
    specification_sheet
    images_page
  end

  def title_pages
    parse(title_pages_src) if title_pages_src
  end

  def summary_page
    parse(summary_page_src) if summary_page_src
  end

  def quote_page
    parse(quote_page_src)
  end

  def specification_sheet
    load(quote.specification_sheet.upload.url) if quote.specification_sheet
  end

  def images_page
    parse(images_page_src) if images_page_src
  end

  def number_pages
    pdf.number_pages \
      location: :bottom,
      number_format: "Page %s of #{pdf.pages.count}",
      margin_from_height: 30,
      font_size: 8
  end

  def parse prawn_doc
    pdf << CombinePDF.parse(prawn_doc.render)
  end

  def load pdf_file_path
    tmpname = Dir::Tmpname.create(['specsheet','.pdf']){}
    IO.binwrite(tmpname, Net::HTTP.get_response(URI.parse(pdf_file_path)).body)
    pdf << CombinePDF.load(tmpname)
    File.rm(tmpname)
    pdf
  end
end
