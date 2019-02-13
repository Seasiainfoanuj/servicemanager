class HireProductType < ActiveRecord::Base

  has_and_belongs_to_many :vehicle_models, join_table: :vehicle_models_hire_product_types

  validates :name, presence: true, uniqueness: true

end