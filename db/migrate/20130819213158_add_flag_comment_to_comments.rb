class AddFlagCommentToComments < ActiveRecord::Migration
  def change
    add_column :comments, :flaged_comment, :boolean
  end
end
