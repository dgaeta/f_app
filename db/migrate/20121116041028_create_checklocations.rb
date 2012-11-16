class CreateChecklocations < ActiveRecord::Migration
  def change
    create_table :checklocations do |t|
      t.integer :requester_id
      t.string :gym_name
      t.float :geo_lat
      t.float :geo_long
      t.integer :number_of_requests

      t.timestamps
    end
  end
end
