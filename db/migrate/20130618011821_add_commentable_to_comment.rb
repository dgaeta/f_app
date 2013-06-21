class AddCommentableToComment < ActiveRecord::Migration
  def change
   t.belongs_to :commentable, polymorphic: true
  end

  add_index :comments, [:commentable_id, :commentable_type]
end
