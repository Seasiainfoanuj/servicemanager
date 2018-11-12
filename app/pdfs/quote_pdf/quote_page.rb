require 'prawn/table'
require "prawn/measurement_extensions"

class QuotePdf
  class QuotePage < Prawn::Document
    def initialize(quote, hide_all_cost_columns, view)
      super(margin: 2.cm, :page_size => "A4")
      define_grid(:columns => 3, :rows => 30, :gutter => 15)#.show_all()
      font_size 9
      @quote = quote
      @hide_all_cost_columns = hide_all_cost_columns
      @view = view

      quote_header
      quote_from
      quote_to
      quote_info
      line_items
      quote_totals

      quote_terms if @quote.terms.present?
      quote_comments if @quote.comments.present?
    end

    def quote_header
      if @quote.invoice_company.logo.present?
        begin
          image @quote.invoice_company.logo.path(:large), width: 120
        rescue
          nil
        end
      end
      move_up 10

      font_size 9

      text "Quote #{@quote.number}", size: 13, style: :bold, align: :right
    end

    def quote_from
      grid([2.5,0], [5,0]).bounding_box do
        fill_color "888888"
        text "From", size: 9, :leading => 3
        fill_color "333333"
        text "#{@quote.invoice_company.name}", style: :bold
        text "#{@quote.invoice_company.address_line_1}"
        text "#{@quote.invoice_company.address_line_2}"
        text "#{@quote.invoice_company.suburb} #{@quote.invoice_company.state} #{@quote.invoice_company.postcode}"
        text "#{@quote.invoice_company.country}"
      end
    end

    def quote_to
      grid([2.5,1], [5,1]).bounding_box do
        fill_color "888888"
        text "Quote For", size: 9, :leading => 3
        fill_color "333333"
        text "#{@quote.customer.name}", style: :bold
        text "#{@quote.customer.company}", style: :bold

        if @quote.customer.postal_address.present?
          postal_address = @quote.customer.addresses.postal.first
          text "#{postal_address.line_1}"
          text "#{postal_address.line_2}"
          text "#{postal_address.suburb} #{postal_address.state} #{postal_address.postcode}"
          text "#{postal_address.country}"
        end
      end
    end

    def quote_info
      if @quote.po_number.present?
        quote_info_table = [["Quote Number","#{@quote.number}"],["Quote Date","#{@quote.date_field}"],["PO Number","#{@quote.po_number}"]]
      else
        quote_info_table = [["Quote Number","#{@quote.number}"],["Quote Date","#{@quote.date_field}"]]
      end
      grid([2.4,1.7], [5,2]).bounding_box do
        table quote_info_table do
          self.width = 7.cm
          cells.padding = [0,0,4,0]
          cells.border_width = 0
          column(0).width = 70
          column(1).font_style = :bold
          column(1).align = :right
        end
      end
    end

    def line_items
      font_size 8

      if @hide_all_cost_columns == true
        table line_item_rows_without_cost do
          self.width = 17.cm
          self.header = true
          row(0).font_style = :bold
          row(0).background_color = "EEEEEE"
          cells.padding = 5
          cells.border_width = 0.2
          cells.border_color = "DDDDDD"
          columns(1).align = :right
          columns(1).width = 40
        end
      else
        table line_item_rows_with_cost do
          self.width = 17.cm
          self.header = true
          row(0).font_style = :bold
          row(0).background_color = "EEEEEE"
          cells.padding = 5
          cells.border_width = 0.2
          cells.border_color = "DDDDDD"
          columns(1..4).align = :right
          column(1).width = 80
          columns(2..3).width = 40
          column(4).width = 80
        end
      end
    end

    def line_item_rows_without_cost
      items = []
      @quote.items.each do |item|
        description_lines = item.description.lines

        items << [description_lines.first, item.quantity]

        description_lines.shift # Remove first line ^^ already displayed
        description_lines.each do |line|
          items << [line, ""]
        end
      end
      [["Description", "Qty"]] + items
    end

    def line_item_rows_with_cost
      items = []
      @quote.items.each do |item|
        if item.tax && item.tax.name
          tax_name = item.tax.name
        else
          tax_name = ""
        end

        if item.hide_cost == true
          display_price = ""
          tax = ""
          line_total = ""
        else
          display_price = price(item.cost_float)
          tax = tax_name
          line_total = price(item.line_total_float)
        end

        description_lines = item.description.lines

        items << [description_lines.first, display_price, item.quantity, tax, line_total]

        description_lines.shift # Remove first line ^^ already displayed
        description_lines.each do |line|
          items << [line, "", "", "", ""]
        end
      end
      [["Description", "Cost", "Qty", "Tax", "Line Total"]] + items
    end

    def quote_totals
      table quote_totals_table do
        self.width = 17.cm
        cells.borders = [:top]
        cells.border_width = 0
        cells.border_color = "DDDDDD"
        cells.padding = 8
        row(0).columns(0..2).border_width = 1
        row(1).columns(1..2).border_width = 0.5
        column(1).width = 70
        column(2).width = 100
        column(2).align = :right
        row(2).column(1..2).font_style = :bold
        row(2).column(1..2).border_width = 1
        row(2).column(1..2).background_color = "F1F1F1"
      end
    end

    def quote_totals_table
      [["","Subtotal","#{price(@quote.subtotal)}"],["","Tax","#{price(@quote.tax_total)}"],["","Quote Total","#{price(@quote.grand_total)}"]]
    end

    def price(num)
      @view.number_to_currency(num)
    end

    def quote_terms
      move_down 40
      text "Terms", size: 13, style: :bold
      move_down 10
      text "#{@quote.terms}"
    end

    def quote_comments
      move_down 40
      text "Comments", size: 13, style: :bold
      move_down 10
      text "#{@quote.comments}"
    end
  end
end
