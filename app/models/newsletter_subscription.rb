class NewsletterSubscription < ActiveRecord::Base

  validates :first_name, presence: true, length: { 
    minimum: 2, maximum: 40, 
    too_short: "is required",
    too_long: "is too long" }

  validates :last_name, presence: true, length: { 
    minimum: 2, maximum: 40, 
    too_short: "is required",
    too_long: "is too long" }

  validates :email, presence: true, email: true, length: { maximum: 255 }
  
  validates :subscription_origin, presence: true

end