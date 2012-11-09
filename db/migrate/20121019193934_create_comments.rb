class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :message
      t.time :stamp
      t.text :first_name
      t.text :last_name 
      t.integer :from_user_id
      t.integer :from_game_id
      t.integer :first_name
      t.integer :last_name

      t.timestamps
    end
  end

  

end
