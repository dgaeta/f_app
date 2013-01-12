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
      t.integer :check_out_geo_lat, :default => 0 #change to double precision in db
      t.integer :check_out_geo_long, :default => 0 #change to double precision in db
      t.text    :full_name
      t.integer :place, :default => 0 
      t.integer :last_checkin_date, :default => 0 

      t.timestamps
    end
  end
end
