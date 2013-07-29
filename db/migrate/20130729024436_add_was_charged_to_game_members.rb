class AddWasChargedToGameMembers < ActiveRecord::Migration
  def change
    add_column :game_members, :was_charged, :boolean, :default => false
  end
end
