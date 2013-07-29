class NotificationsController < ApplicationController
  before_filter :load_notifiable

  def index
  	@notification = @notifiable.notifications
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

  def show_user_notifications
    @user = User.where(:id => params[:user_id]).first 
    new_notifications_count = @user.notifications.where(:opened => false).count

    if @user 
      notifications = @user.notifications
      notifications = notifications.map do |notif|
       {:_id => notif.id,
        :content => notif.content,
        :sender_id => notif.sender_id,
        :contains_sender_profile_pic => User.find(notif.sender_id).pluck(s3_profile_pic_name).nil?,
        :sender_profile_pic =>  (bucket_for_prof_pics.objects[@user.s3_profile_pic_name].url_for(:read, :expires => 10*60)),
        :message => notif.message,
        :game_id => notif.game_id,
        :comment_id => notif.comment_id,
        :opened => notif.opened, 
        :new_notifications_count => new_notifications_count}
      end 
      notifications_json =  { :status => "okay", :notifications => notifications }
      render(json: JSON.pretty_generate(notifications_json))
    else 
      error_json =  { :status => "no user found"}
      render(json: JSON.pretty_generate(error_json))
    end 
  end





private 
  def load_notifiable
    klass = [Game, User, ProfilePicture].detect { |n| params["#{n.name.underscore}_id"]}
    @notifiable = klass.find(params["#{klass.name.underscore}_id"])
  end
end
