class Comment < ActiveRecord::Base
 belongs_to :user
  attr_accessible :id, :message, :stamp, :from_user_id, :first_name, :last_name, :from_game_id
  #attr_accessor :game_member_id, :message, :stamp
 

	def self.gameStartComment(game_id)
      @comment = Comment.new(:from_game_id => game.id , :from_user_id => 101,  :email => "team@fitsby.com",
      :bold => "TRUE", :first_name => "ANNOUNCEMENT",  :last_name => " " , :message => "The game has started!",
      :stamp => Time.now)
      @comment.email = "team@fitsby.com"
      @comment.from_user_id = 101
      @comment.bold = "TRUE"
      @comment.save
  	end

	def self.gamePostponedComment(game_id)
	  @comment = Comment.new(:from_game_id => game.id, :email => "team@fitsby.com", :from_user_id => 101, :first_name => "ANNOUNCEMENT", 
	  :last_name => " " , :bold => "TRUE", 
      :message => "The game start date has been pushed forward 1 day! (Need at least 2 players).", 
      :stamp => Time.now)
      @comment.email = "team@fitsby.com"
      @comment.from_user_id = 101
      @comment.bold = "TRUE"
      @comment.save
	end




 end
