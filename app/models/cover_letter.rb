class CoverLetter < ActiveRecord::Base
  belongs_to :covering_subject, polymorphic: true

  validates :title, presence: true
  validates :content, presence: true

end
