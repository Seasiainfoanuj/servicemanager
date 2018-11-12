class Image < ActiveRecord::Base
# http://stackoverflow.com/questions/4076041/paperclip-how-do-you-upload-pdfs
  belongs_to :imageable, polymorphic: true
  belongs_to :document_type
  belongs_to :photo_category

  DOCUMENT = 0
  PHOTO = 1

  validates :image_type, presence: true,
                         inclusion: { in: [0,1] }
  validates :name, presence: true,
                   length: { minimum: 3, maximum: 50 }  
  validates :description, length: { maximum: 255 }  
  # validates :image, presence: true

  has_attached_file :image, 
    styles: {
      thumb:  '100x100>',
      medium: '200x200>',
      large:  '640x640>',
      pdf_thumbnail: ["", :jpg]
    },
    default_url: "/images/:style/missing.png"
  validates_attachment_size :image, :less_than => 10.megabytes
  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/png', 'image/gif', 'application/pdf', 'application/msword', 'text/plain', 'text/xml']

  scope :documents, -> { where(image_type: DOCUMENT) }
  scope :photos, -> { where(image_type: PHOTO) }

  def image_type_name
    case image_type
    when DOCUMENT
      'document'
    when PHOTO
      'photo'
    end  
  end
end
