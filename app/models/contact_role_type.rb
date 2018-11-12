class ContactRoleType < ActiveRecord::Base

  has_and_belongs_to_many :users, join_table: :contacts_roles

  validates :name, presence: true, uniqueness: true

end