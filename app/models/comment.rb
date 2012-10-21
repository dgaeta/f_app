class Comment < ActiveRecord::Base
 belongs_to :game_member
  attr_accessible :from_id, :gametocomments_id, :message, :stamp
end
