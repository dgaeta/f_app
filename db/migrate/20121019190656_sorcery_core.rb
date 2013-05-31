class SorceryCore < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      #t.string :username,         :null => false  # if you use another field as a username, for example email, you can safely remove this field.
      t.text   :email,            :default => nil # if you use this field as a username, you might want to make it :null => false.
      t.text   :first_name
      t.text   :last_name
      t.string :crypted_password, :default => nil
      t.string :salt,             :default => nil
      t.text   :customer_id, :default => 0 
      t.integer :token, :default => 0
      t.integer :num_of_texts, :default => 0 
      t.boolean :device_registered, :default => false
      t.integer :check_in_geo_lat, :default => 0 #change to double precision in db
      t.integer :check_in_geo_long, :default => 0 #change to double precision in db
      t.integer :enable_notifications, :default => 1
      t.string  :reset_password_token
      t.datetime :reset_password_token_expires_at
      t.datetime :reset_password_email_sent_at
      t.datetime :last_login_at
      t.datetime :last_logout_at
      t.datetime :last_activity_at
      t.string   :remember_me_token
      t.datetime :remember_me_token_expires_at

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end