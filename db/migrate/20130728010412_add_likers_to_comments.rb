class AddLikersToComments < ActiveRecord::Migration
  def change
    add_column :comments, :likers, :string, :default => ""
  end
end
