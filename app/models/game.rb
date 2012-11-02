class Game < ActiveRecord::Base
  
  belongs_to :user
  has_many :game_members, :dependent => :destroy
  has_many :comments, :dependent => :destroy,  :through => :game_members
  attr_accessible :creator_id, :duration, :is_private, :wager, :players, :stakes, :game_start_date, :game_end_date, :creator_first_name
end
