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
    new_notifications_count = @user.notifications.where(:was_opened => "FALSE").count
    s3 = AWS::S3.new
    bucket_for_prof_pics = s3.buckets['profilepics.fitsby.com']

    if @user 
      notifications = @user.notifications
      unless notifications.count == 0 
        notifications = notifications.map do |notif|
         {:_id => notif.id,
          :content => notif.content,
          :sender_id => notif.sender_id,
          :contains_sender_profile_pic => User.where(:id => notif.sender_id).pluck(:s3_profile_pic_name).nil?,
          :sender_profile_pic =>  (bucket_for_prof_pics.objects[User.where(:id => notif.sender_id).pluck(:s3_profile_pic_name)].url_for(:read, :expires => 10*60)),
          :message => notif.message,
          :game_id => notif.game_id,
          :comment_id => notif.comment_id,
          :was_opened => notif.was_opened}
        end 
        notifications_json =  { :status => "okay", :notifications => notifications, :new_notifications_count => new_notifications_count }
        render(json: JSON.pretty_generate(notifications_json))
      else 
        error_json =  { :status => "no user found"}
        render(json: JSON.pretty_generate(error_json))
      end 
    end 
  end

  def open_notification
    @notification = Notification.where(:id => params[:notification_id]).first 

    if @notification
      @notification.was_opened = "TRUE"
      @notification.save
      success_json =  { :status => "okay"}
      render(json: JSON.pretty_generate(success_json))
    else 
      error_json =  { :status => "no notification found"}
      render(json: JSON.pretty_generate(error_json))
    end
  end





private 
  def load_notifiable
    klass = [Game, User, ProfilePicture].detect { |n| params["#{n.name.underscore}_id"]}
    unless klass.nil?
      @notifiable = klass.find(params["#{klass.name.underscore}_id"])
    end
end
end
