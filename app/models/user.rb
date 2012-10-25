class User < ActiveRecord::Base
   
  has_many :games, :class_name => "Game", :foreign_key => "creator_id", :dependent => :destroy 
  has_many :game_members,  :dependent => :destroy
  has_many :comments, :dependent => :destroy, :through => :game_members
  has_many :stats, :class_name => "Stat", :foreign_key => "winners_id",:dependent => :destroy 
  
  authenticates_with_sorcery!
  attr_accessible :email, :first_name, :last_name, :password, :password_confirmation

  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_presence_of :first_name
  validates_presence_of :last_name



end
