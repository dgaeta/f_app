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
  get "number_of_players" => "game_members#number_of_players", :as => "number_of_players"

  
  root :to => "landings#index"
end