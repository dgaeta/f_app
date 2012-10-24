class Game < ActiveRecord::Base
  belongs_to :user
  has_many :game_members
  has_many :comments, :through => :game_members
  attr_accessible :creator_id, :duration, :is_private, :wager, :players, :stakes
end
