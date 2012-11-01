class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.integer :winners_id
      t.integer :money_earned
      t.integer :games_won
      t.integer :games_played
      t.integer :first_place_finishes
      t.integer :second_place_finishes
      t.integer :third_place_finishes
      t.integer :losses

      t.timestamps
    end
  end
end
