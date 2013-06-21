class AddCommentableToComment < ActiveRecord::Migration
  def up
      
   end
  	
 add_column :comments, :commentable_id, :integer, :commentable_type, :string
  add_index :comments, [:commentable_id, :commentable_type]
end
