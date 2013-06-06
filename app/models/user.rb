class User < ActiveRecord::Base
  
   
  has_many :games, :class_name => "Game", :foreign_key => "creator_id", :dependent => :destroy 
  has_many :game_members,  :dependent => :destroy
  has_many :comments, :class_name => "Comment", :foreign_key => "from_user_id", :dependent => :destroy
  has_many :stats, :class_name => "Stat", :foreign_key => "winners_id",:dependent => :destroy 
  
  authenticates_with_sorcery!
  attr_accessible :email, :first_name, :last_name, :password, :password_confirmation, :customer_id

  #validates :password_confirmation, :presence => :true
  validates :password, :presence => :true, :length => { :minimum => 6 }, :on => :create, :confirmation => :true
  validates :email, :presence => :true, :uniqueness => true, :length => { :minimum => 6}, :format => {:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i}
  validates_presence_of :first_name
  validates_presence_of :last_name

  def self.deleteUser(user_id)
    @user = User.where(:id => user_id).first
    players = GameMember.where(:user_id => @user.id, :is_game_over => "FALSE")
    
    if players.empty?
      stat = Stat.where(:winners_id => @user.id).first
      stat.delete
      players =  GameMember.where(:user_id => @user_id)
      players.each { |p| p.delete }
      games = Game.where(:creator_id => @user.id)
      unless games.empty?
        games.each do |game| 
          game.creator_id = 101
          game.save 
        end
      end 
      puts "User" + user.id + "deleted"
      user.delete
    end
  end

end