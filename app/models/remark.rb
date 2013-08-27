class Remark < ActiveRecord::Base
  attr_accessible :content, :from_user_id, :message, :remarkable_id, :remarkable_type
  belongs_to :remarkable, polymorphic: true


  def self.create_remark_for_client(content, message, from_user_id, comment_id)
	  comment = Comment.find(comment_id)
	  remark = comment.remarks.create!(content: content, message: message, from_user_id: from_user_id)

	  return remark 
  end

=begin  def self.timestamp_minutes(remark_id)
  	@remark = Remark.find(remark.id)

  	timestampe = @remark.
  	timestamp_string = 
  end
=end
  def self.get_remarks(comment_id)
      comment = Comment.where(:id => comment_id).first
      remarks = comment.remarks.last(4)
      remarks = remarks.map do |remark|
      {:remark_id => remark.id, 
      :content => remark.content,
      :message => remark.message, 
      :from_user_id => remark.from_user_id,
      :from_user_fullname => User.get_full_name(remark.from_user_id),
      :commentable_id => remark.remarkable_id
      #:profile_picture_status_hash => User.deliver_profile_picture(remark.from_user_id)
       }
    end
    return remarks 
  end

end
