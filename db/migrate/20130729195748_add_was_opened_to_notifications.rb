class AddWasOpenedToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :was_opened, :boolean, :default => "FALSE"
  end
end
