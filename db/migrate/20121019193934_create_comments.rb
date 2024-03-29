class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :message
      t.text :stamp
      t.text :first_name
      t.text :last_name 
      t.integer :from_user_id
      t.integer :from_game_id
      t.integer :first_name
      t.integer :last_name
      t.text :email 
      t.boolean :bold, :default => "False"
      t.boolean :checkin, :default => "False"
      t.boolean :self_made

      t.timestamps
    end
  end
   add_index :comments, [:commentable_id, :commentable_type]
  

end

