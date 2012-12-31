class SorceryCore < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      #t.string :username,         :null => false  # if you use another field as a username, for example email, you can safely remove this field.
      t.text   :email,            :default => nil # if you use this field as a username, you might want to make it :null => false.
      t.text   :first_name
      t.text   :last_name
      t.string :crypted_password, :default => nil
      t.string :salt,             :default => nil
      t.text   :customer_id
      t.integer :token, :default => 0
      t.integer :num_of_texts, :default => 0 
      t.integer :device_id
      t.real :check_in_geo_lat, :default => 0 
      t.real :check_in_geo_long, :default => 0 

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end