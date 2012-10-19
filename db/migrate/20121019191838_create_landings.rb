class CreateLandings < ActiveRecord::Migration
  def change
    create_table :landings do |t|

      t.timestamps
    end
  end
end
