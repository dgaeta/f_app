class Friendship < ActiveRecord::Base
  attr_accessible :friend_id, :user_id, :status, :friend_first_name, :friend_last_name
  belongs_to :user
  belongs_to :friend, :class_name => "User"
  has_many :notifications, as: :notifiable
end
