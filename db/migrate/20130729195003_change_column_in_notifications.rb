class ChangeColumnInNotifications < ActiveRecord::Migration
  def up
  	remove_column :notifications, :opened
  end

  def down
  	add_column :notifications, :opened, :boolean, :default => "FALSE"
  end
end
