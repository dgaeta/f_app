class AddCommentableToComments < ActiveRecord::Migration
  def change
  	#add_column :comments, :commentable_id, :integer ####uncomment if recreating database
	#add_column :comments, :commentable_type, :string
	#add_index :comments, [:commentable_id, :commentable_type]
  end
    
  

end
