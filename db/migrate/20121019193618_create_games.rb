class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :creator_id
      t.boolean :is_private
      t.integer :duration
      t.integer :wager
      t.integer :players
      t.integer :stakes
      t.integer :game_end_date
      t.integer :game_start_date

      t.timestamps
    end
  end
end
