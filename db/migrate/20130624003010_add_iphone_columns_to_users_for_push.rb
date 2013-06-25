class AddIphoneColumnsToUsersForPush < ActiveRecord::Migration
  def change
    add_column :users_for_pushes, :iphone_device_token, :string
  end
end
