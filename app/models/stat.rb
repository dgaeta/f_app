class Stat < ActiveRecord::Base
  attr_accessible :games_played, :games_won, :money_earned, :winners_id
end
