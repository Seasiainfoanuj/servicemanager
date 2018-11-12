class CreateNewsletterSubscriptions < ActiveRecord::Migration
  def change
    create_table :newsletter_subscriptions do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :subscription_origin

      t.timestamps null: false
    end
  end
end
