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

ActiveRecord::Schema.define(:version => 20121019194134) do

  create_table "comments", :force => true do |t|
    t.integer  "game_member_id"
    t.text     "message"
    t.time     "stamp"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "comments", ["game_member_id"], :name => "fki_from_id"

  create_table "game_members", :force => true do |t|
    t.integer  "game_id"
    t.integer  "user_id"
    t.integer  "successful_checks"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "checkins"
    t.integer  "checkouts"
  end

  add_index "game_members", ["game_id"], :name => "fki_game_id"
  add_index "game_members", ["user_id"], :name => "fki_user_id"

  create_table "games", :force => true do |t|
    t.integer  "creator_id"
    t.boolean  "is_private"
    t.integer  "duration"
    t.integer  "wager"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "players"
    t.integer  "stakes"
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
    t.integer  "money_earned"
    t.integer  "games_won"
    t.integer  "games_played"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "stats", ["winners_id"], :name => "fki_winners_id"

  create_table "users", :force => true do |t|
    t.text     "email"
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.text     "first_name"
    t.text     "last_name"
  end

end
