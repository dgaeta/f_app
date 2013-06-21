class AddCommentableToComment < ActiveRecord::Migration
  def up
       add_column :comments, :commentable_id, :integer, :commentable_type, :string
   end
  	

  add_index :comments, [:commentable_id, :commentable_type]
end
