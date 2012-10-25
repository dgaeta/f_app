class GameMember < ActiveRecord::Base
  has_many :comments, :dependent => :destroy
  belongs_to :game, :dependent => :destroy
  belongs_to :user, :dependent => :destroy
  attr_accessible :checkins, :checkouts, :game_id, :successful_checks, :user_id
end
