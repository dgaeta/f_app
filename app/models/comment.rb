class Comment < ActiveRecord::Base
 belongs_to :user
  attr_accessible :id, :message, :stamp, :from_user_id, :first_name, :last_name, :from_game_id, :comment_type, :image_name, :profile_picture_name, :contains_profile_picture, :likes, :likers
  belongs_to :commentable, polymorphic: true
  has_many :notifications, as: :notifiable
  has_many :remarks, as: :remarkable
  #attr_accessor :game_member_id, :message, :stamp
 

	def self.gameStartComment(game_id)
      @comment = Comment.new(:from_game_id => game_id , :from_user_id => 101,  :email => "team@fitsby.com",
      :bold => "TRUE", :first_name => "ANNOUNCEMENT",  :last_name => " " , :message => "The game has started!",
      :stamp => Time.now)
      @comment.email = "team@fitsby.com"
      @comment.from_user_id = 101
      @comment.bold = "TRUE"
      @comment.save
  	end

	def self.gamePostponedComment(game_id)
	  @comment = Comment.new(:from_game_id => game_id, :email => "team@fitsby.com", :from_user_id => 101, :first_name => "ANNOUNCEMENT", 
	  :last_name => " " , :bold => "TRUE", 
      :message => "The game start date has been pushed forward 1 day! (Need at least 2 players).", 
      :stamp => Time.now)
      @comment.email = "team@fitsby.com"
      @comment.from_user_id = 101
      @comment.bold = "TRUE"
      @comment.save
	end


  def self.deleteEntireGamesComments(game_id)
    begin 
     comment = Comment.where(:from_game_id => 346).first
     comment.destroy 
   end until (Comment.where(:from_game_id => 346).first == nil)
  end

  def self.getfeed(get_page, pagecount, game_id, user_id)
    s3 = AWS::S3.new
    bucket_for_comments = s3.buckets['images.fitsby.com']
    bucket_for_prof_pics = s3.buckets['profilepics.fitsby.com']
   
    #page divide the newsfeed into 10 records, when a user goes past the first 10 records. we will change get_page parameter to 2
    comments_from_given_page = Comment.where(:from_game_id => params[:game_id]).order("created_at DESC").limit(10).offset( 1 * get_page)

    comments_from_given_page = comments_from_given_page.map do |comment|
     {:_id => comment.id,
      :user_id => comment.from_user_id,
      :contains_profile_picture => comment.contains_profile_picture,
      #:profile_picture_name =>  (bucket_for_prof_pics.objects[comment.s3_profile_pic_name].url_for(:read, :expires => 10*60)),
      :first_name => comment.first_name,
      :last_name => comment.last_name,
      :message => comment.message,
      :email => comment.email,
      :liked_by_user =>  comment.likers.include?(user_id.to_s), 
      :number_of_likes => comment.likes,
      :likers => comment.likers.split(',').map {|n| n = User.get_full_name(n).downcase}, 
      :bold => comment.bold,
      :checkin => comment.checkin,
      :comment_type => comment.comment_type,
      :image_name => (bucket_for_comments.objects[comment.image_name].url_for(:read, :expires => 10*60)),
      :stamp => comment.created_at.strftime("%-I:%M%p (%m/%d/%y)"), 
      :remarks_array_with_count => Remark.get_remarks(comment.id)}
    end

    if comments_from_given_page == nil 
      then 
        false_json = { :status => "fail."} 
        render(json: JSON.pretty_generate(false_json))
      else
        true_json =  { :status => "okay" , :comments_from_given_page => comments_from_given_page }
        render(json: JSON.pretty_generate(true_json))
    end    
  end


 end
