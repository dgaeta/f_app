class AddTwoColumnsToComments < ActiveRecord::Migration
  def change
    add_column :comments, :image_name, :string
    add_column :comments, :type, :string
  end
end
