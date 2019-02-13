require "prawn/measurement_extensions"

class QuotePdf
  class TitlePages < Prawn::Document
    def initialize(quote)
      super(margin: 2.cm, :page_size => "A4")
      define_grid(:columns => 3, :rows => 30, :gutter => 20)#.show_all()
      font_size 9
      @quote = quote

      quote_title_page if @quote.title_page.present?
      quote_cover_letter if @quote.cover_letter.present?
    end

    def quote_title_page
      rectangle [395, 841], 180, 900
      fill_color "000000"
      fill
      begin
        image @quote.invoice_company.logo.path(:large), width: 220 if @quote.invoice_company.logo.present?
      rescue
        nil
      end  

      move_down 5

      image @quote.title_page.image_1.path(:title_page), width: 390 if @quote.title_page.image_1.present?

      move_down 5

      image @quote.title_page.image_2.path(:title_page), width: 390 if @quote.title_page.image_2.present?

      move_down 12

      bounding_box([0,cursor], :width => 380) do
        font_size 13
        text @quote.title_page.title, style: :bold, align: :center
      end

      move_down 10

      stroke_color "DDDDDD"
      dash([2], :phase => 1)
      stroke_horizontal_line 0, 380, :at => cursor
      undash()

      move_down 10
      bounding_box([10,cursor], :width => 380) do
        font_size 10

        text "#{@quote.customer.name}"
        text "#{@quote.customer.job_title}" if @quote.customer.job_title.present?
        text "#{@quote.customer.company}" if @quote.customer.company.present?

        move_down 5

        if @quote.customer.postal_address.present?
          postal_address = @quote.customer.postal_address
          if postal_address.line_1.present? && postal_address.line_2.present?
            address = "#{postal_address.line_1}, " + "#{postal_address.line_2},"
          elsif postal_address.line_1.present?
            address = "#{postal_address.line_1},"
          elsif postal_address.line_2.present?
            address = "#{postal_address.line_2},"
          else
            address = nil
          end

          text "#{address} #{@quote.customer.postal_address.suburb} " +
               "#{@quote.customer.postal_address.state} " +
               "#{@quote.customer.postal_address.postcode} " +
               "#{@quote.customer.postal_address.country}"

          move_down 5
        end
        text "Email: #{@quote.customer.email}" if @quote.customer.email.present?
        text "Phone: #{@quote.customer.phone}" if @quote.customer.phone.present?
        text "Mobile: #{@quote.customer.mobile}" if @quote.customer.mobile.present?
      end

      bounding_box([395,720], :width => 140) do
        fill_color "FFFFFF"
        stroke_color "FFFFFF"

        text "BUS 4x4 Group of Companies", style: :bold, align: :center

        move_down 10
        stroke_horizontal_line 40, 100, :at => cursor
      end

      move_down 120

      list_companies \
        "Bus 4x4 Australia",
        "Bus 4x4 Japan",
        "4x4 Tour Bus Australia",
        "4x4 Motorhomes Australia"

      move_down 150

      bounding_box([395,cursor], :width => 140) do
        text "#{@quote.invoice_company.address_line_1}", size: 11, align: :center
        text "#{@quote.invoice_company.address_line_2}", size: 11, align: :center

        text "#{@quote.invoice_company.suburb} " +
             "#{@quote.invoice_company.state} " +
             "#{@quote.invoice_company.postcode}", size: 11, align: :center

        text "#{@quote.invoice_company.country}", size: 11, align: :center

        move_down 20

        text @quote.invoice_company.website, size: 11, align: :center

        move_down 20

        text "#{@quote.date.strftime("%-d %B %Y")}", size: 11, align: :center
      end

      fill_color "333333"
      start_new_page if @quote.cover_letter.present?
    end

    def quote_cover_letter
      fill_color "333333"
      font_size 10

      move_down 10

      if @quote.invoice_company.logo
        image @quote.invoice_company.logo.path(:large), width: 180
      end

      bounding_box([20, cursor], :width => bounds.width-40) do
        text @quote.invoice_company.address_line_1, align: :right if @quote.invoice_company.address_line_1.present?
        text @quote.invoice_company.address_line_2, align: :right if @quote.invoice_company.address_line_2.present?

        text "#{@quote.invoice_company.suburb}, " +
             "#{@quote.invoice_company.state} " +
             "#{@quote.invoice_company.postcode}", align: :right

        text @quote.invoice_company.country, align: :right

        text "ACN: #{@quote.invoice_company.acn}", align: :right if @quote.invoice_company.acn.present?
        text "ABN: #{@quote.invoice_company.abn}", align: :right if @quote.invoice_company.abn.present?

        move_down 10

        if @quote.invoice_company.phone.present?
          text "Phone: #{@quote.invoice_company.phone}", align: :right
        end

        if @quote.invoice_company.fax.present?
          text "Fax: #{@quote.invoice_company.fax}", align: :right
        end

        text @quote.customer.name
        text @quote.customer.company if @quote.customer.company.present?

        if @quote.customer.postal_address.present?
          postal_address = @quote.customer.addresses.postal.first
          if postal_address.line_1.present? && postal_address.line_2.present?
            address = "#{postal_address.line_1}, " +
                      "#{postal_address.line_2},"
          elsif postal_address.line_1.present?
            address = "#{postal_address.line_1},"
          elsif postal_address.line_2.present?
            address = "#{postal_address.line_2},"
          else
            address = nil
          end

          text "#{address} #{postal_address.suburb} " +
               "#{postal_address.state} " +
               "#{postal_address.postcode} " +
               "#{postal_address.country}"
        end

        text "Email: #{@quote.customer.email}" if @quote.customer.name != "[#{@quote.customer.email}]"
        text "Phone: #{@quote.customer.phone}" if @quote.customer.phone.present?
        text "Mobile: #{@quote.customer.mobile}" if @quote.customer.mobile.present?

        move_down 20

        text @quote.cover_letter.title, size: 11, style: :bold, align: :center

        move_down 20

        text @quote.cover_letter.text if @quote.cover_letter.text.present?
      end
    end

    private

    def list_companies *companies
      companies.each do |company|
        bounding_box([395,cursor], :width => 140) do
          text company, align: :center

          move_down 20
          stroke_horizontal_line 40, 100, :at => cursor
        end

        move_down 30
      end
    end
  end
end
