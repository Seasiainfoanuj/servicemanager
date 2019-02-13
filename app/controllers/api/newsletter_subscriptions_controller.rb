class Api::NewsletterSubscriptionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :create

  def show
  end

  def create
    @subscription = NewsletterSubscription.new(subscription_params)
    existing_subscription = NewsletterSubscription.find_by(email: @subscription.email)
    if existing_subscription
      render action: 'show', status: :created, location: api_newsletter_subscription_path(existing_subscription)
    else
      if @subscription.save
        render action: 'show', status: :created, location: api_newsletter_subscription_path(@subscription)
      else
        render status: :unprocessable_entity, json: @subscription.errors
      end 
    end
  end

  private
    def subscription_params
      params.require(:newsletter_subscription).permit(
        :first_name,
        :last_name,
        :email,
        :subscription_origin
      )
    end
end
