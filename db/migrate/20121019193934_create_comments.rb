class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :game_member_id
      t.text :message
      t.time :stamp
      

      t.timestamps
    end
  end

  

end
