class AddFieldsToFriendships < ActiveRecord::Migration
  def change
    add_column :friendships, :friend_first_name, :string
    add_column :friendships, :friend_last_name, :string
  end
end
