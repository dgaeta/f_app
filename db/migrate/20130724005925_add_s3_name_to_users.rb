class AddS3NameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :s3_profile_pic_name, :string
  end
end
