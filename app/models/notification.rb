class Notification < ActiveRecord::Base
  attr_accessible :content, :opened, :receiver_id, :sender_id
  belongs_to :notifiable, polymorphic: true
end
