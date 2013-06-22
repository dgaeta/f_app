class RemoveSillyAuthenticationFieldsWhichShouldNotBeThere < ActiveRecord::Migration
	def change 
      remove_column :friendships, :create
      remove_column :friendships, :destroy
   end
  def up
  end

  def down
  end
end
