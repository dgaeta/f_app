class Game < ActiveRecord::Base
  belongs_to :user
  attr_accessible :creator_id, :duration, :is_private, :wager
end
