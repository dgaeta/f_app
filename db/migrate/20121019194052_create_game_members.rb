class CreateGameMembers < ActiveRecord::Migration
  def change
    create_table :game_members do |t|
      t.integer :game_id
      t.integer :user_id
      t.integer :checkins
      t.integer :checkouts
      t.integer :successful_checks
      t.integer :final_standing
      t.integer :daily_checkins
      t.integer :total_minutes_at_gym

      t.timestamps
    end
  end
end
