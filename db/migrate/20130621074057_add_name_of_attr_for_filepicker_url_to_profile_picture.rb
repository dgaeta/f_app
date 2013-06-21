class AddNameOfAttrForFilepickerUrlToProfilePicture < ActiveRecord::Migration
   def up
        add_column :profile_pictures, :filepicker_url, :string
    end

    def down
        remove_column :profile_pictures, :filepicker_url
    end
end
