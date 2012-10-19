class GameMember < ActiveRecord::Base
  attr_accessible :checkins, :checkouts, :game_id, :successful_checks, :user_id
end
