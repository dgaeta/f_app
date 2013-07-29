class AddGameIdAndMessageToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :game_id, :integer
    add_column :notifications, :message, :string
  end
end
