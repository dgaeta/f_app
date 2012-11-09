FApp::Application.routes.draw do
  get "password_resets/create"

  get "password_resets/edit"

  get "password_resets/update"

  resources :stats

  resources :game_members

  resources :comments

  resources :games

  resources :landings

  resources :sessions

  resources :users

  resources :password_resets

 get "logout" => "sessions#destroy", :as => "logout"
  get "login" => "sessions#new", :as => "login"
  get "log_in" => "sessions#create", :as => "log_in"
  get "signup" => "users#new", :as => "signup"
  get "gamecomments" => "comments#gamecomments", :as => "gamecomments"
  get "stakes" => "game_members#stakes", :as => "stakes"
  get "check_in_request" => "game_members#check_in_request", :as => "check_in_request"
  get "check_out_request" => "game_members#check_out_request", :as => "check_out_request"
  get "leaderboard" => "game_members#leaderboard", :as => "leaderboard"
  get "number_of_players" => "game_members#number_of_players", :as => "number_of_players"
  get "join_game" => "games#join_game", :as => "join_game"
  get "create_game" => "games#create_game", :as => "create_game"
  get "user_stats" => "stats#user_stats", :as => "user_stats"
  get "public_games" => "games#public_games", :as => "public_games"
  get "new" => "users#new", :as => "new"
  get "users" => "users#create", :as => "users"
  get "index" => "users#index", :as => "index"
  get "winners_and_losers" => "games#winners_and_losers", :as => "winners_and_losers"
  get "can_game_start_date" => "games#can_game_start_date", :as => "can_game_start_date"
  get "can_game_start_players" => "games#can_game_start_players", :as => "can_game_start_players"
  get "can_game_end" => "games#can_game_end", :as => "can_game_end"
  get "game_comments" => "comments#game_comments", :as => "game_comments"
  get "countdown" => "games#countdown", :as => "countdown"
  get "get_private_game_info" => "games#get_private_game_info", :as => "get_private_game_info"
  get "login_android" => "sessions#create", :as => "login_android"

  #stripe route
  get "get_and_save_stripe_info" => "users#get_and_save_stripe_info", :as => "get_and_save_stripe_info"

  match "games#create_game" => "create_game#post"
  match "games#login_android" => "login_android#post"








  
  root :to => "landings#index"
end