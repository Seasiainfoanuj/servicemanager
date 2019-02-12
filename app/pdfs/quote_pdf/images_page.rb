require "prawn/measurement_extensions"

class QuotePdf
  class ImagesPage < Prawn::Document
    def initialize(quote)
      super(margin: 2.cm, :page_size => "A4")
      define_grid(:columns => 3, :rows => 30, :gutter => 20)#.show_all()
      font_size 9
      @quote = quote

      quote_pics
    end

    def quote_pics
      return if @quote.attachments.none?
      @quote.attachments.each_with_index do |file, inx|
        next if file.upload_content_type == 'application/pdf'
        y_pos = cursor
        if y_pos < 5.cm
          start_new_page
          y_pos = cursor
        end
        next_line = inx % 2 == 0
        if next_line
          pos = [0, y_pos]
        else
          pos = [8.5.cm, y_pos]
        end  
        image file.upload.path(:medium), width: 8.25.cm, at: pos
        move_down 6.5.cm unless next_line
      end
    end
  end
end
