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


 end
