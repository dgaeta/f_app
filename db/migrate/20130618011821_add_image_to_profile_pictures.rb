class AddImageToProfilePictures < ActiveRecord::Migration
  def change
    add_column :profile_pictures, :image
  end
end
