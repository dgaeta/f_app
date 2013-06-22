class AddCommentableToComments < ActiveRecord::Migration
  def change
  end
  def up
	   add_column :comments, :commentable_id, :integer
	   add_column :comments, :commentable_type, :string
   end
  add_index :comments, [:commentable_id, :commentable_type]

end
