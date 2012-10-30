class Comment < ActiveRecord::Base
 belongs_to :game_member
  attr_accessible :id, :game_member_id, :message, :stamp, :from_id
  #attr_accessor :game_member_id, :message, :stamp
 end
