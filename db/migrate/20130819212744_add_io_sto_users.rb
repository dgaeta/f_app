class AddIoStoUsers < ActiveRecord::Migration
  def change
    add_column :users, :iOS_udid, :string
  end
end
