class ProfilePicture < ActiveRecord::Base
  belongs_to :user
  attr_accessible :user_id, :image, :filepicker_url
  has_many :comments, as: :commentable
  mount_uploader :image, ImageUploader
end
