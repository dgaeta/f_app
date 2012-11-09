class GameMember < ActiveRecord::Base
  has_many :comments, :dependent => :destroy
  belongs_to :game 
  belongs_to :user
  attr_accessible :checkins, :checkouts, :game_id, :successful_checks, :user_id
end
