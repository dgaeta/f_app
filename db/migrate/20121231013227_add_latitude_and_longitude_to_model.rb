class AddLatitudeAndLongitudeToModel < ActiveRecord::Migration
  def change
    add_column :models, :latitude, :float
    add_column :models, :longitude, :float
  end
end
