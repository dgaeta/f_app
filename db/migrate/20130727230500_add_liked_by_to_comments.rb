class AddLikedByToComments < ActiveRecord::Migration
  def change
    add_column :comments, :liked_by, :string
  end
end
