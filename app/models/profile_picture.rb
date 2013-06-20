class ProfilePicture < ActiveRecord::Base
  belongs_to :user
  attr_accessible :user_id, :image, :remote_image_url

  mount_uploader :image, ImageUploader
end
