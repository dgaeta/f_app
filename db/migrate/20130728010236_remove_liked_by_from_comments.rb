class RemoveLikedByFromComments < ActiveRecord::Migration
  def up
    remove_column :comments, :liked_by
  end

  def down
    add_column :comments, :liked_by, :string
  end
end
