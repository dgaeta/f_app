class CreateDecidedlocations < ActiveRecord::Migration
  def change
    create_table :decidedlocations do |t|
      t.float :geo_lat
      t.float :geo_long
      t.string :gym_name
      t.integer :decision

      t.timestamps
    end
  end
end
