class ChangeIndexNameOnComments < ActiveRecord::Migration
  def up
    rename_column :comments, :type, :comment_type

  end

  def down
  end
end
