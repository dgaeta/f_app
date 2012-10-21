class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :from_id
      t.integer :gametocomments
      t.text :message
      t.time :stamp
      

      t.timestamps
    end
  end

  

end
