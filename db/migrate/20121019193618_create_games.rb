class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :creator_id
      t.boolean :is_private
      t.integer :duration
      t.integer :wager, :default => 0
      t.integer :players
      t.integer :stakes
      t.integer :game_end_date
      t.integer :game_start_date
      t.string  :creator_first_name
      t.integer :game_initialized, :default => 0
      t.integer :game_active, :default => 1
      t.integer :winning_structure, :default => 3
      t.integer :was_recently_initiated, :default => 0

      t.timestamps
    end
  end
end
