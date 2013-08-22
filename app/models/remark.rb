class Remark < ActiveRecord::Base
  attr_accessible :content, :from_user_id, :message, :remarkable_id, :remarkable_type
  belongs_to :remarkable, polymorphic: true


  def self.create_remark_for_client(content, message, from_user_id, comment_id)
	  comment = Comment.find(comment_id)
	  remark = comment.remarks.create!(content: content, message: message, from_user_id: from_user_id)

	  return remark 
  end

end
