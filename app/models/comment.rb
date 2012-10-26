class Comment < ActiveRecord::Base
 belongs_to :game_member
  attr_accessible :id, :game_member_id, :message, :stamp
  #attr_accessor :game_member_id, :message, :stamp
 end
