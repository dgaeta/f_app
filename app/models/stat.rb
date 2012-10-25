class Stat < ActiveRecord::Base
  belongs_to :user	
  attr_accessible :games_played, :games_won, :money_earned, :winners_id, :first_place_finishes, :second_place_finishes, 
  :third_place_finishes, :losses


end
