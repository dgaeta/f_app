class CreateGameMembers < ActiveRecord::Migration
  def change
    create_table :game_members do |t|
      t.integer :game_id
      t.integer :user_id
      t.integer :checkins, :default => 0
      t.integer :checkouts, :default => 0
      t.integer :successful_checks, :default => 0
      t.integer :final_standing, :default => 0
      t.integer :daily_checkins, :default => 0
      t.integer :total_minutes_at_gym, :default => 0
      t.integer :end_game_checks_evaluation, :default => 0

      t.timestamps
    end
  end
end
