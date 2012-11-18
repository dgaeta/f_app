class CreateDecidedlocations < ActiveRecord::Migration
  def change
    create_table :decidedlocations do |t|
      t.float :geo_lat
      t.float :geo_long
      t.string :gym_name
      t.integer :decision
      t.integer :number_of_requests, :default => 1

      t.timestamps
    end
  end
end
