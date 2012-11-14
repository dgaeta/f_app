class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.integer :winners_id
      t.integer :money_earned,:default => 0
      t.integer :games_won, :default => 0
      t.integer :games_played, :default => 0
      t.integer :first_place_finishes, :default => 0
      t.integer :second_place_finishes, :default => 0
      t.integer :third_place_finishes, :default => 0
      t.integer :losses, :default => 0

      t.timestamps
    end
  end
end
