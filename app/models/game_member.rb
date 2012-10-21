class GameMember < ActiveRecord::Base
  has_many :comments
  belongs_to :game
  attr_accessible :checkins, :checkouts, :game_id, :successful_checks, :user_id
end
