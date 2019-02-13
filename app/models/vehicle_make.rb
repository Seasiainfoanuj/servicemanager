class VehicleMake < ActiveRecord::Base

  has_many :models, :class_name => "VehicleModel"

  validates :name, presence: true,
                   uniqueness: true,
                   length: { minimum: 2, maximum: 50 }

end
