class User < ActiveRecord::Base
   
  has_many :games, :class_name => "Game", :foreign_key => "creator_id", :dependent => :destroy 
  has_many :game_members,  :dependent => :destroy
  has_many :comments
  has_many :stats, :class_name => "Stat", :foreign_key => "winners_id",:dependent => :destroy 
  
  authenticates_with_sorcery!
  attr_accessible :email, :first_name, :last_name, :password, :password_confirmation, :customer_id

  #validates :password_confirmation, :presence => :true
  validates :password, :presence => :true, :length => { :minimum => 6 }, :on => :create, :confirmation => :true
  validates :email, :presence => :true, :uniqueness => true, :length => { :minimum => 6}, :format => {:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i}
  validates_presence_of :first_name
  validates_presence_of :last_name



end
