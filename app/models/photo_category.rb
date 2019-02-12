class PhotoCategory < ActiveRecord::Base

  validates :name, uniqueness: true,
                   length: { minimum: 5, maximum: 40 }

end
