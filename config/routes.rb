FApp::Application.routes.draw do
  resources :stats

  resources :game_members

  resources :comments

  resources :games

  resources :landings

  resources :sessions

  resources :users

 get "logout" => "sessions#destroy", :as => "logout"
  get "login" => "sessions#new", :as => "login"
  get "signup" => "users#new", :as => "signup"
  get "gamecomments" => "comments#gamecomments", :as => "gamecomments"
  get "stakes" => "game_members#stakes", :as => "stakes"
  get "check_in_request" => "game_members#check_in_request", :as => "check_in_request"
  get "check_out_request" => "game_members#check_out_request", :as => "check_out_request"
  get "leaderboard" => "game_members#leaderboard", :as => "leaderboard"
  get "number_of_players" => "game_members#number_of_players", :as => "number_of_players"
  get "join_game" => "game_members#join_game", :as => "join_game"
  get "create_game" => "games#create_game", :as => "create_game"
  get "user_stats" => "stats#user_stats", :as => "user_stats"
  get "public_games" => "games#public_games", :as => "public_games"
  get "new" => "users#new", :as => "new"




  
  root :to => "landings#index"
end