class Friendship < ActiveRecord::Base
  attr_accessible :create, :destroy, :friend_id, :user_id, :status
  belongs_to :user
  belongs_to :friend, :class_name => "User"
  has_many :notifications, as: :notifiable
end
