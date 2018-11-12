module NotesHelper
  def link_to_add_note_uploads(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render("shared/notes/upload_fields", f: builder)
    end
    link_to(name.html_safe, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end

  # def display_date(date)
  #   date.strftime("%d/%m/%Y")
  # end

end
