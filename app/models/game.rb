class Game < ActiveRecord::Base
  attr_accessible :creator_id, :duration, :is_private, :wager
end
