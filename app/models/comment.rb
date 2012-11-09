class Comment < ActiveRecord::Base
 belongs_to :user
  attr_accessible :id, :message, :stamp, :from_user_id, :first_name, :last_name, :from_game_id
  #attr_accessor :game_member_id, :message, :stamp
 end
