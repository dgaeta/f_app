class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.integer :winners_id
      t.integer :money_earned
      t.integer :games_won
      t.integer :games_played

      t.timestamps
    end
  end
end
