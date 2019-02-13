class MailgunController < ApplicationController

  before_filter :authenticate_user!

  add_crumb "Mailgun"

  def log
    authorize! :view, :mailgun_log
    @mailgun_log = Mailgun().log.list(limit: 300)
    add_crumb 'Log'
  end

  def bounces
    authorize! :view, :mailgun_bounces
    @mailgun_bounces = Mailgun().bounces.list(limit: 300)
    add_crumb 'Bounces'
  end
end
