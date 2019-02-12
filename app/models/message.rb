class Message < ActiveRecord::Base

  belongs_to :sender, :class_name => "User"
  belongs_to :recipient, :class_name => "User"
  belongs_to :workorder
  belongs_to :hire_agreement
  belongs_to :quote

  validates :sender, presence: true
  validates :recipient, presence: true

end
