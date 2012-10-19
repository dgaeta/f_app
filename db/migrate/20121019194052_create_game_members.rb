class CreateGameMembers < ActiveRecord::Migration
  def change
    create_table :game_members do |t|
      t.integer :game_id
      t.integer :user_id
      t.integer :checkins
      t.integer :checkouts
      t.integer :successful_checks

      t.timestamps
    end
  end
end
