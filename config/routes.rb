FApp::Application.routes.draw do

  ###EXCEPTIONS HANDLING
  match '(errors)/:status', to: 'errors#show', constraints: {status: /\d{3}/} # via: :all
 
  resources :aws_pictures

  resources :profile_pictures do 
    resources :comments
    resources :notifications
  end
  get "profile_pictures_destroy" => "profile_pictures#destroy", :as => "profile_pictures_destroy"
  match "profile_pictures_destroy", :to => "profile_pictures#destroy", :via => "delete" 
 

 #Landing page routes
  resources :landings
  root :to => "landings#index"
  match 'about',    to: 'landings#about'
  match 'contact',  to: 'landings#contact'
  match 'FAQ',      to: 'landings#frequently_asked_questions'
  match 'terms',    to: 'landings#terms'
  match 'privacy',  to: 'landings#privacy'
  match 'blog',     to: 'landings#blog'
  

 


  resources :stats do 
    resources :comments
  end
  get "user_stats" => "stats#user_stats", :as => "user_stats"
  ###
  match "user_stats", :to => "stats#user_stats", :via => "get"

  
  resources :game_members
  get "stakes" => "game_members#stakes", :as => "stakes"
  get "check_in_request" => "game_members#check_in_request", :as => "check_in_request"
  get "check_out_request" => "game_members#check_out_request", :as => "check_out_request"
  get "leaderboard" => "game_members#leaderboard", :as => "leaderboard"
  get "number_of_players" => "game_members#number_of_players", :as => "number_of_players"
  get "games_user_is_in" => "game_members#games_user_is_in", :as => "games_user_is_in"
  get "push_position_change" => "game_members#push_position_change", :as => "push_position_change"
  ###
  match "check_out_request", :to => "game_members#check_out_request", :via => "post"
  match "check_in_request", :to => "game_members#check_in_request", :via => "post"
  match "number_of_players", :to => "game_members#number_of_players", :via => "get"
  match "games_user_is_in", :to => "game_members#games_user_is_in", :via => "get"
  match "push_position_change", :to => "game_members#push_position_change", :via => "post"


  resources :comments
  get "deleteSingleComment"          => "comments#deleteSingleComment",          :as => "deleteSingleComment"
  get "deleteEntireGamesComments"    => "comments#deleteEntireGamesComments",    :as => "deleteEntireGamesComments"
  get "deleteSingleCommentAPI"       => "comments#deleteSingleCommentAPI",       :as => "deleteSingleCommentAPI"
  get "deleteEntireGamesCommentsAPI" => "comments#deleteEntireGamesCommentsAPI", :as => "deleteEntireGamesCommentsAPI"
  get "gamecomments" => "comments#gamecomments", :as => "gamecomments"
  get "game_comments" => "comments#game_comments", :as => "game_comments"
  get "post_comment" => "comments#post_comment", :as => "post_comment"
  get "multimedia_message" => "comments#multimedia_message", :as => "multimedia_message"
  get "like_comment" => "comments#like_comment", :as => "like_comment"
  ###
  match "game_comments", :to => "comments#game_comments", :via => "get"
  match "post_comment", :to => "comments#post_comment", :via => "post"
  match "multimedia_message", :to => "comments#multimedia_message", :via => "post"
  match "like_comment", :to => "comments#like_comment", :via => "post"



  resources :games do 
    resources :comments
    resources :notifications
  end
  get "join_game" => "games#join_game", :as => "join_game"
  get "create_game" => "games#create_game", :as => "create_game"
  get "public_games" => "games#public_games", :as => "public_games"
  get "winners_and_losers" => "games#winners_and_losers", :as => "winners_and_losers"
  get "can_game_start_date" => "games#can_game_start_date", :as => "can_game_start_date"
  get "can_game_start_players" => "games#can_game_start_players", :as => "can_game_start_players"
  get "can_game_end" => "games#can_game_end", :as => "can_game_end"
  get "countdown" => "games#countdown", :as => "countdown"
  get "get_private_game_info" => "games#get_private_game_info", :as => "get_private_game_info"
  get "single_game_info" => "games#single_game_info", :as => "single_game_info"
  get "auto_init_games_and_end_games" => "games#auto_init_games_and_end_games", :as => "auto_init_games_and_end_games"
  get "auto_end_games" => "games#auto_end_games", :as => "auto_end_games"
  get "auto_start_games" => "games#auto_start_games", :as => "auto_start_games"
  get "get_first_name" => "games#get_first_name", :as => "get_first_name"
  get "percentage_of_game" => "games#percentage_of_game", :as => "percentage_of_game"
  get "add_gyms_to_google" => "games#add_games_to_google", :as => "add_games_to_google"
  get "countdown2" => "games#countdown2", :as => "countdown2"
  ###
  match "games#create_game" => "create_game#post"
  match "games#login_android" => "login_android#post"
  match "create_game", :to => "games#create_game", :via => "post"
  match "create_game", :to => "games#create_game", :via => "post"
  match "join_game", :to => "games#join_game", :via => "post"
  match "leaderboard", :to => "games#leaderboard", :via => "get"
  match "single_game_info", :to => "games#single_game_info", :via => "get"
  match "get_first_name", :to => "games#get_first_name", :via => "get"
  match "percentage_of_game", :to => "games#percentage_of_game", :via => "get"
  match "countdown2", :to => "games#countdown2", :via => "get"

  

  resources :sessions
  get "logout" => "sessions#destroy", :as => "logout"
  get "login" => "sessions#new", :as => "login"
  get "log_in" => "sessions#create", :as => "log_in"
  get "login_android" => "sessions#login_android", :as => "login_android"
  get "logout" => "sessions#destroy", :as => "logout"
  ###
  match "login_android", :to => "sessions#login_android", :via => "post"

  

  resources :users do 
    resources :comments
    resources :notifications
  end
  get "signup" => "users#new", :as => "signup"
  get "new" => "users#new", :as => "new"
  get "users" => "users#create", :as => "users"
  get "index" => "users#index", :as => "index"
  get "push_enable" => "users#push_enable", :as => "push_enable"
  get "push_disable" => "users#push_disable", :as => "push_disable"
  get "append_text_field" => "users#append_text_field", :as => "append_text_field"
  get "user_deletion" => "users#user_deletion", :as => "user_deletion" 
  get "checkPushRegistration" => "users#checkPushRegistration", :as => "checkPushRegistration" 
  get "get_and_save_stripe_info" => "users#get_and_save_stripe_info", :as => "get_and_save_stripe_info"
  get "createUser" => "users#createUser", :as => "createUser"
  get "does_customer_id_exist" => "users#does_customer_id_exist", :as => "does_customer_id_exist"
  get "upload_profile_picture" => "users#upload_to_s3", :as => "upload_profile_picture"
  get "get_user_profile_picture" => "users#get_user_profile_picture", :as => "get_user_profile_picture"
  ###
  match "get_and_save_stripe_info", :to => "users#get_and_save_stripe_info", :via => "post"
  match "change_password", :to => "users#change_password", :via => "put"  
  match "append_text_field", :to => "users#append_text_field", :via => "post"
  match "push_registration", :to => "users#push_registration", :via => "post"
  match "push_enable", :to => "users#push_enable", :via => "post"
  match "push_disable", :to => "users#push_disable", :via => "post"
  match "upload_profile_picture", :to => "users#upload_profile_picture", :via => "post"
  match "user_deletion", :to => "users#user_deletion", :via => "post"
  match "checkPushRegistration", :to => "users#checkPushRegistration", :via => "post"
  match "createUser", :to => "users#createUser", :via => "post"
  match "signin_facebook", :to => "users#signin_facebook", :via => "post"
  match "does_customer_id_exist", :to => "users#does_customer_id_exist", :via => "get"
  match "signup", :to => "users#create", :via => "post"
  match "upload_profile_picture", :to => "users#upload_to_s3", :via => "post" 
  match "get_user_profile_picture", :to => "users#get_user_profile_picture", :via => "get" 

  resources :password_resets
  get "reset_password" => "password_resets#create", :as => "reset_password"
  get "change_password" => "password_resets#change_password", :as => "change_password"
  get "change_pw_request" => "password_resets#change_pw_request", :as => "change_pw_request"
  get "update_email" => "password_resets#update_email", :as => "update_email"
  get "password_resets/create"
  get "password_resets/edit"
  get "password_resets/update"
  ###
  match "reset_password", :to => "password_resets#create", :via => "get"
  match "update_email", :to => "password_resets#update_email", :via => "post"
  match 'reset_password',     to: 'password_resets#create'


  resources :decidedlocations

  resources :checklocations
  get "validate_gym" => "checklocations#validate_gym", :as => "validate_gym"
  ###
  match "validate_gym", :to => "checklocations#validate_gym", :via => "post"  

 resources :friendships
 get "friendship/create" => "friendships#create", :as => "friendship/create"
 get "friendship/destroy" => "friendships#destroy", :as => "friendship/destroy"
 match "friendship/create", :to => "friendships#create", :via => "post" 
 match "friendship/destroy", :to => "friendships#destroy", :via => "delete" 

 resources :notifications
  get "show_user_notifications" => "notifications#show_user_notifications", :as => "show_user_notifications"
  match "show_user_notifications", :to => "notifications#show_user_notifications", :via => "post" 

end