class Comment < ActiveRecord::Base
 belongs_to :game_member
  attr_accessible :game_member_id, :message, :stamp
end
