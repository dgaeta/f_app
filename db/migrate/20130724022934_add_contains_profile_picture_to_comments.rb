class AddContainsProfilePictureToComments < ActiveRecord::Migration
  def change
    add_column :comments, :contains_profile_picture, :boolean, :default => "FALSE"
  end
end
