class AddProfilePictureNameToComments < ActiveRecord::Migration
  def change
    add_column :comments, :profile_picture_name, :string, :default => "none"
  end
end
