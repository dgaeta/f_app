class AddS3NameToProfilePictures < ActiveRecord::Migration
  def change
    add_column :profile_pictures, :s3_name, :string
  end
end
