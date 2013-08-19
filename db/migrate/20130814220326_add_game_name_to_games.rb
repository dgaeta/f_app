class AddGameNameToGames < ActiveRecord::Migration
  def change
    add_column :games, :game_name, :string
  end
end
