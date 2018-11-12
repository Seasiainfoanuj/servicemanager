class DocumentType < ActiveRecord::Base

  validates :name, uniqueness: true,
                   length: { minimum: 5, maximum: 40 }
  validates :label_color, presence: true

end
