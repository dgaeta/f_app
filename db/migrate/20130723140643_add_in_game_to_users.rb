class AddInGameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :in_game, :integer
  end
end
