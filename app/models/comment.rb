class Comment < ActiveRecord::Base
  attr_accessible :from_id, :message, :stamp
end
