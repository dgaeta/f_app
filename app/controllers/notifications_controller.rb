class NotificationsController < ApplicationController
  before_filter :load_notifiable

  def index
  	@notifications = @notifiable.notifications
  end

  def new
  	 @notification = @notifiable.notifications.new
  end

  def create
  @notification = @notifiable.notifications.new(params[:notification])
  if @notification.save
    redirect_to [@notifiable, :notifications], notice: "Notification created."
  else
    render :new
  end
end


private 
  def load_notifiable
  klass = [Game, User, ProfilePicture].detect { |n| params["#{n.name.underscore}_id"]}
  @notifiable = klass.find(params["#{klass.name.underscore}_id"])
end
end
