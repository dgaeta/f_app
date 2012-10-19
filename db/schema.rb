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
    t.integer  "from_id"
    t.text     "message"
    t.time     "stamp"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "game_members", :force => true do |t|
    t.integer  "game_id"
    t.integer  "user_id"
    t.integer  "checkins"
    t.integer  "checkouts"
    t.integer  "successful_checks"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "games", :force => true do |t|
    t.integer  "creator_id"
    t.boolean  "is_private"
    t.integer  "duration"
    t.integer  "wager"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

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

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

end
