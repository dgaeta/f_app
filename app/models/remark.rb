class Remark < ActiveRecord::Base
  attr_accessible :content, :from_user_id, :message, :remarkable_id, :remarkable_type
  belongs_to :remarkable, polymorphic: true
end
