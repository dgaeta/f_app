class AddIphoneColumnsToUsersForPush < ActiveRecord::Migration
  def change
    add_column :users, :iphone_device_token, :string
  end
end
