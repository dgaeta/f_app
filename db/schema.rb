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

ActiveRecord::Schema.define(:version => 20130723140643) do

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
    t.text     "message"
    t.text     "stamp"
    t.text     "first_name"
    t.text     "last_name"
    t.integer  "from_user_id"
    t.integer  "from_game_id"
    t.text     "email"
    t.boolean  "bold",             :default => false
    t.boolean  "checkin",          :default => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.boolean  "self_made"
    t.integer  "commentable_id"
    t.text     "commentable_type"
    t.string   "image_name"
    t.string   "comment_type"
  end

  add_index "comments", ["commentable_id", "commentable_type"], :name => "index_comments_on_commentable_id_and_commentable_type"

  create_table "decidedlocations", :force => true do |t|
    t.float    "geo_lat"
    t.float    "geo_long"
    t.string   "gym_name"
    t.integer  "decision"
    t.integer  "number_of_requests", :default => 1
    t.integer  "added_to_google",    :default => 0
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "friendships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.text     "status"
  end

  create_table "game_members", :force => true do |t|
    t.integer  "game_id"
    t.integer  "user_id"
    t.integer  "checkins",                   :default => 0
    t.integer  "checkouts",                  :default => 0
    t.integer  "successful_checks",          :default => 0
    t.integer  "final_standing",             :default => 0
    t.integer  "daily_checkins",             :default => 0
    t.integer  "total_minutes_at_gym",       :default => 0
    t.integer  "end_game_checks_evaluation", :default => 0
    t.integer  "check_out_geo_lat",          :default => 0
    t.integer  "check_out_geo_long",         :default => 0
    t.text     "full_name"
    t.integer  "place",                      :default => 0
    t.integer  "last_checkin_date",          :default => 0
    t.integer  "activated_at",               :default => 0
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.boolean  "is_game_over",               :default => false
    t.integer  "last_checkout_date",         :default => 0
    t.integer  "active",                     :default => 0
  end

  create_table "games", :force => true do |t|
    t.integer  "creator_id"
    t.boolean  "is_private"
    t.integer  "duration"
    t.integer  "wager",                  :default => 0
    t.integer  "players"
    t.integer  "stakes"
    t.integer  "game_end_date"
    t.integer  "game_start_date"
    t.string   "creator_first_name"
    t.integer  "game_initialized",       :default => 0
    t.integer  "game_active",            :default => 1
    t.integer  "winning_structure",      :default => 3
    t.integer  "was_recently_initiated", :default => 0
    t.integer  "goal_days"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  create_table "landings", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "notifications", :force => true do |t|
    t.text     "content"
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.integer  "notifiable_id"
    t.string   "notifiable_type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "notifications", ["notifiable_id", "notifiable_type"], :name => "index_notifications_on_notifiable_id_and_notifiable_type"

  create_table "oauth_access_grants", :force => true do |t|
    t.integer  "resource_owner_id", :null => false
    t.integer  "application_id",    :null => false
    t.string   "token",             :null => false
    t.integer  "expires_in",        :null => false
    t.string   "redirect_uri",      :null => false
    t.datetime "created_at",        :null => false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], :name => "index_oauth_access_grants_on_token", :unique => true

  create_table "oauth_access_tokens", :force => true do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id",    :null => false
    t.string   "token",             :null => false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        :null => false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], :name => "index_oauth_access_tokens_on_refresh_token", :unique => true
  add_index "oauth_access_tokens", ["resource_owner_id"], :name => "index_oauth_access_tokens_on_resource_owner_id"
  add_index "oauth_access_tokens", ["token"], :name => "index_oauth_access_tokens_on_token", :unique => true

  create_table "oauth_applications", :force => true do |t|
    t.string   "name",         :null => false
    t.string   "uid",          :null => false
    t.string   "secret",       :null => false
    t.string   "redirect_uri", :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "oauth_applications", ["uid"], :name => "index_oauth_applications_on_uid", :unique => true

  create_table "profile_pictures", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "image"
    t.string   "filepicker_url"
  end

  create_table "push_configurations", :force => true do |t|
    t.string   "type",                           :null => false
    t.string   "app",                            :null => false
    t.text     "properties"
    t.boolean  "enabled",     :default => false, :null => false
    t.integer  "connections", :default => 1,     :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "push_feedback", :force => true do |t|
    t.string   "app",                             :null => false
    t.string   "device",                          :null => false
    t.string   "type",                            :null => false
    t.string   "follow_up",                       :null => false
    t.datetime "failed_at",                       :null => false
    t.boolean  "processed",    :default => false, :null => false
    t.datetime "processed_at"
    t.text     "properties"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "push_feedback", ["processed"], :name => "index_push_feedback_on_processed"

  create_table "push_messages", :force => true do |t|
    t.string   "app",                                  :null => false
    t.string   "device",                               :null => false
    t.string   "type",                                 :null => false
    t.text     "properties"
    t.boolean  "delivered",         :default => false, :null => false
    t.datetime "delivered_at"
    t.boolean  "failed",            :default => false, :null => false
    t.datetime "failed_at"
    t.integer  "error_code"
    t.string   "error_description"
    t.datetime "deliver_after"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "push_messages", ["delivered", "failed", "deliver_after"], :name => "index_push_messages_on_delivered_and_failed_and_deliver_after"

  create_table "sessions", :force => true do |t|
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "user_id"
    t.boolean  "deleted",       :default => false
    t.integer  "request_month"
    t.integer  "reques_day"
    t.integer  "request_year"
  end

  create_table "stats", :force => true do |t|
    t.integer  "winners_id"
    t.integer  "money_earned",          :default => 0
    t.integer  "games_won",             :default => 0
    t.integer  "games_played",          :default => 0
    t.integer  "first_place_finishes",  :default => 0
    t.integer  "second_place_finishes", :default => 0
    t.integer  "third_place_finishes",  :default => 0
    t.integer  "losses",                :default => 0
    t.integer  "total_minutes_at_gym",  :default => 0
    t.integer  "successful_checks",     :default => 0
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  create_table "users", :force => true do |t|
    t.text     "email"
    t.text     "first_name"
    t.text     "last_name"
    t.string   "crypted_password"
    t.string   "salt"
    t.text     "customer_id",                     :default => "0"
    t.integer  "token",                           :default => 0
    t.integer  "num_of_texts_sent",               :default => 0
    t.integer  "check_in_geo_lat",                :default => 0
    t.integer  "check_in_geo_long",               :default => 0
    t.integer  "enable_notifications",            :default => 1
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.datetime "last_login_at"
    t.datetime "last_logout_at"
    t.datetime "last_activity_at"
    t.string   "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.string   "gcm_registration_id"
    t.string   "in_games"
    t.boolean  "device_registered",               :default => false
    t.integer  "num_of_games",                    :default => 0
    t.integer  "comments_made",                   :default => 0
    t.integer  "game_history",                    :default => 0
    t.integer  "signup_month"
    t.integer  "signup_day"
    t.integer  "signup_year"
    t.integer  "gamess"
    t.string   "iphone_device_token"
    t.string   "provider"
    t.string   "uid"
    t.integer  "in_game"
  end

  add_index "users", ["last_logout_at", "last_activity_at"], :name => "index_users_on_last_logout_at_and_last_activity_at"
  add_index "users", ["remember_me_token"], :name => "index_users_on_remember_me_token"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token"

end
