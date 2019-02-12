class MessagesController < ApplicationController

  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_message, only: [:show, :edit, :update, :destroy]
  before_filter :set_mailer_host

  add_crumb('Messages') { |instance| instance.send :messages_path }

  def index
    @messages = Message.all
  end

  def show
    add_crumb "Message to #{@message.recipient.name.capitalize}"
  end

  def new
    @messages = Message.new
    add_crumb 'New Message'
  end

  def create
    @messages = Message.new(message_params)
    if @workorder.save
      flash[:success] = "Message created."
      redirect_to(:action => 'index')
    else
      render('new')
    end
  end

  def edit
    add_crumb "Edit Message to #{@message.recipient.name.capitalize}"
  end

  def update
    if @message.update_attributes(message_params)
      flash[:success] = "Message updated."
      redirect_to(:action => 'index')
    else
      render('edit')
    end
  end

  def destroy
    if @message.destroy
      flash[:success] = "Message deleted."
      redirect_to(:action => 'index')
    end
  end

private

  def set_message
    @message = Message.find(params[:id])
  end

  def message_params
    params.require(:message).permit(
      :sender_id,
      :recipient_id,
      :workorder_id,
      :quote_id,
      :hire_agreement_id,
      :comments
    )
  end

  def set_mailer_host
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end

end
