FApp::Application.routes.draw do
  resources :decidedlocations

  resources :checklocations

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
  get "login_android" => "sessions#login_android", :as => "login_android"
  get "games_user_is_in" => "game_members#games_user_is_in", :as => "games_user_is_in"
  get "post_comment" => "comments#post_comment", :as => "post_comment"
  get "change_email" => "users#change_email", :as => "change_email"
  get "single_game_info" => "games#single_game_info", :as => "single_game_info"
  get "auto_init_games_and_end_games" => "games#auto_init_games_and_end_games", :as => "auto_init_games_and_end_games"
  get "auto_end_games" => "games#auto_end_games", :as => "auto_end_games"
  get "auto_start_games" => "games#auto_start_games", :as => "auto_start_games"
  get "get_first_name" => "games#get_first_name", :as => "get_first_name"
  get "reset_password" => "password_resets#create", :as => "reset_password"
  get "change_password" => "password_resets#change_password", :as => "change_password"
  get "change_email" => "password_resets#change_email", :as => "change_email"
  get "validate_gym" => "checklocations#validate_gym", :as => "validate_gym"
  get "logout" => "sessions#destroy", :as => "logout"
  get "change_pw_request" => "password_resets#change_pw_request", :as => "change_pw_request"
  get "percentage_of_game" => "games#percentage_of_game", :as => "percentage_of_game"



  #stripe route
  get "get_and_save_stripe_info" => "users#get_and_save_stripe_info", :as => "get_and_save_stripe_info"

  match "games#create_game" => "create_game#post"
  match "games#login_android" => "login_android#post"

  match "login_android", :to => "sessions#login_android", :via => "post"
  match "create_game", :to => "games#create_game", :via => "post"
  match "create_game", :to => "games#create_game", :via => "post"
  match "get_and_save_stripe_info", :to => "users#get_and_save_stripe_info", :via => "post"
  match "join_game", :to => "games#join_game", :via => "post"
  match "check_out_request", :to => "game_members#check_out_request", :via => "post"
  match "check_in_request", :to => "game_members#check_in_request", :via => "post"
  match "game_comments", :to => "comments#game_comments", :via => "get"
  match "leaderboard", :to => "games#leaderboard", :via => "get"
  match "number_of_players", :to => "game_members#number_of_players", :via => "get"
  match "user_stats", :to => "stats#user_stats", :via => "get"
  match "post_comment", :to => "comments#post_comment", :via => "post"
  match "change_email", :to => "users#change_email", :via => "put"
  match "single_game_info", :to => "games#single_game_info", :via => "get"
  match "change_password", :to => "users#change_password", :via => "put"  
  match "games_user_is_in", :to => "game_members#games_user_is_in", :via => "get"
  match "get_first_name", :to => "games#get_first_name", :via => "get"
  match "reset_password", :to => "password_resets#create", :via => "get"
  match "change_email", :to => "password_resets#change_email", :via => "post"
  match "validate_gym", :to => "checklocations#validate_gym", :via => "post"
  match "percentage_of_game", :to => "games#percentage_of_game", :via => "get"








  
  root :to => "landings#index"
end