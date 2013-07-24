class AddContainsProfilePictureToUsers < ActiveRecord::Migration
  def change
    add_column :users, :contains_profile_picture, :boolean, :default => "FALSE"
  end
end
