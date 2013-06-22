class Notifications < ActiveRecord::Base
  attr_accessible :content, :notifiable_id, :notifiable_type, :opened, :receiver_id, :sender_id
end
