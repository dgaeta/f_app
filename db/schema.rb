# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121116041338) do

  create_table "checklocations", :force => true do |t|
    t.integer  "requester_id"
    t.string   "gym_name"
    t.float    "geo_lat"
    t.float    "geo_long"
    t.integer  "number_of_requests"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "comments", :force => true do |t|
    t.integer  "from_user_id"
    t.text     "message"
    t.time     "stamp"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.text     "first_name"
    t.text     "last_name"
    t.integer  "from_game_id"
  end

  add_index "comments", ["from_user_id"], :name => "fki_from_id"

  create_table "decidedlocations", :force => true do |t|
    t.float    "geo_lat"
    t.float    "geo_long"
    t.string   "gym_name"
    t.integer  "decision"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "game_members", :force => true do |t|
    t.integer  "game_id"
    t.integer  "user_id"
    t.integer  "successful_checks",          :default => 0
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.integer  "checkins",                   :default => 0
    t.integer  "checkouts",                  :default => 0
    t.integer  "final_standing",             :default => 0
    t.integer  "total_minutes_at_gym",       :default => 0
    t.integer  "daily_checkins",             :default => 0
    t.integer  "end_game_checks_evaluation", :default => 0
  end

  add_index "game_members", ["game_id"], :name => "fki_game_id"
  add_index "game_members", ["user_id"], :name => "fki_user_id"

  create_table "games", :force => true do |t|
    t.integer  "creator_id"
    t.boolean  "is_private"
    t.integer  "duration"
    t.integer  "wager"
    t.datetime "created_at",                        :null => false
    t.time     "updated_at",                        :null => false
    t.integer  "players"
    t.integer  "stakes"
    t.integer  "game_start_date"
    t.integer  "game_end_date"
    t.text     "creator_first_name"
    t.integer  "game_initialized",   :default => 0
    t.integer  "game_active",        :default => 1
  end

  add_index "games", ["creator_id"], :name => "fki_creator_id"

  create_table "landings", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sessions", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "stats", :force => true do |t|
    t.integer  "winners_id"
    t.integer  "money_earned",          :default => 0
    t.integer  "games_won",             :default => 0
    t.integer  "games_played",          :default => 0
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.integer  "first_place_finishes",  :default => 0
    t.integer  "second_place_finishes", :default => 0
    t.integer  "third_place_finishes",  :default => 0
    t.integer  "losses",                :default => 0
    t.integer  "total_minutes_at_gym",  :default => 0
    t.integer  "successful_checks",     :default => 0
  end

  add_index "stats", ["winners_id"], :name => "fki_winners_id"

  create_table "users", :force => true do |t|
    t.text     "email"
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.text     "first_name"
    t.text     "last_name"
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.text     "customer_id"
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.datetime "last_activity_at"
    t.string   "remember_me_token"
    t.datetime "remember_me_token_expires_at"
  end

  add_index "users", ["last_logout_at", "last_activity_at"], :name => "index_users_on_last_logout_at_and_last_activity_at"
  add_index "users", ["remember_me_token"], :name => "index_users_on_remember_me_token"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token"

end
