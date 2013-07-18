class AddFieldsToAwsPicture < ActiveRecord::Migration
  def change
    add_column :aws_pictures, :photo_file_name, :string
    add_column :aws_pictures, :photo_content_type, :string
    add_column :aws_pictures, :photo_file_size, :integer
  end
end
