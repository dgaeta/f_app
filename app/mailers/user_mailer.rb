class UserMailer < ActionMailer::Base
  default from: "Fitsby Team <team@fitsby.com>"

   def welcome_email(user) ##make nice view
    @user = user
    @url  = "http://fitsby.com"
    mail(:to => user.email, :subject => "Welcome to Fitsby, #{@user.first_name}!")
  end

  def congratulate_winner_of_game(winner_email, winner_first_name, game_id, player_cut) ##make views
    @winner_email = winner_email
    @winner_first_name = winner_first_name
    @player_cut = sprintf("%.2f", player_cut)
    @url  = "http://fitsby.com"
    mail(:to => @winner_email, :subject => "Congrats #{@winner_first_name}, you earned $#{@player_cut}!")
  end

  def congratulate_winner_of_free_game(winner_email, winner_first_name) ##make views
    @winner_email = winner_email
    @winner_first_name = winner_first_name
    @url  = "http://fitsby.com"
    mail(:to => @winner_email, :subject => "Congrats #{@winner_first_name}, you earned $#{@player_cut}!")
  end


  def notify_loser_of_free_game(game_id, loser_email, loser_first_name, loser_user_id, loser_checkins )   ##make view
    @game_id = game_id
    @loser_email = loser_email
    @loser_first_name = loser_first_name
    @loser_user_id = loser_user_id
    @loser_checkins = loser_checkins
    @url  = "http://fitsby.com"
    mail(:to => loser_email, :subject => "Oh no #{@loser_first_name}! You just lost a game of Fitsby")
  end

  def notify_loser_of_paid_game(money_lost, game_id, loser_email, loser_first_name, loser_user_id, 
        loser_checkins)
    @money_lost = money_lost
    @game_id = game_id
    @loser_email = loser_email
    @loser_first_name = loser_first_name
    @loser_user_id = loser_user_id
    @loser_checkins = loser_checkins
    @url  = "http://fitsby.com"
    mail(:to => loser_email, :subject => "Oh no #{@loser_first_name}! You just lost a game of Fitsby")
  end


  def email_ourselves_to_pay_winner_of_game(game_id, winner_first_name, winner_email, winner_user_id, 
  player_cut, fitsby_money_won, total_money_processed)   ##make view
    @game_id = game_id
    @winner_first_name = winner_first_name
    @winner_email = winner_email
    @winner_user_id = winner_user_id
    @player_cut = sprintf("%.2f",player_cut)
    @fitsby_money_won = sprintf("%.2f", fitsby_money_won)
    @total_money_processed = total_money_processed
    @url  = "http://fitsby.com"
    mail(:to => "payments@fitsby.com", :subject => "Pay User")
  end


  def reset_password_email(user)
  @user = user
  @url  = "http://0.0.0.0:3000/password_resets/#{user.reset_password_token}/edit"
  mail(:to => user.email,
       :subject => "Your password has been reset")
  end


def check_location_mailer(user, geo_lat, geo_long, gym_name, user_email, string, number_of_requests)
    @user = user
    @user_email = user_email
    @geo_lat = geo_lat
    @geo_long = geo_long
    @gym_name = gym_name
    @string = string 
    @url  = "http://fitsby.com"
    mail(:to => "gyms@fitsby.com", :subject => "location related request from user #{@user_id}!")

end

def decided_location_mailer(user, geo_lat, geo_long, gym_name, user_email, string, decision)
    @user = user
    @user_email = user_email
    @decision = decision
    @geo_lat = geo_lat
    @geo_long = geo_long
    @gym_name = gym_name
    @string = string 
    @url  = "http://fitsby.com"
    mail(:to => "gyms@fitsby.com", :subject => "location related request from user #{@user_id}!")

end

def additional_request_for_undecided_location(user, user_email, string, gym_name, number_of_requests_for_gym, decidedlocations_id, number_of_requests_by_user)
    @user = user
    @user_email = user_email
    @gym_name = gym_name
    @string = string 
    @number_of_requests_for_gym = number_of_requests_for_gym
    @number_of_requests_by_user = number_of_requests_by_user
    @decidedlocations_id = decidedlocations_id
    @url  = "http://fitsby.com"
    mail(:to => "gyms@fitsby.com", :subject => "location related request from user #{@user_id}!")
  end

  def notify_game_start(game_member_id, user_email, game_id)
    @user = game_member_id
    @user_email = user_email
    @game_id = game_id
    @url  = "http://fitsby.com"
    mail(:to => @user_email, :subject => "Your Fitsby game number #{@user_id} has started!")
  end

   def notify_new_game_start(game_member_id, user_email, game_id, new_start_date)
    @user = game_member_id
    @user_email = user_email
    @game_id = game_id
    @new_start_date = new_start_date
    @url  = "http://fitsby.com"
    mail(:to => @user_email, :subject => "Your Fitsby game number #{@user_id} start date has been moved!")
  end

  def reset_password_email(user)
  @user = user
  @url  = "http://f-app.herokuapp.com/password_resets/#{user.reset_password_token}/edit"
  mail(:to => user.email,
       :subject => "Your password has been reset")
  end

  def change_pw_request(email, token, first_name)
  @email = email
  @token  = token
  mail(:to => @email,
       :subject => "Looks like you forgot your password.")
  end

  def testing_checkin_to_checkout(user_id, game_member_id, check_in_time, successful_checks_before, geo_lat, geo_long)
    @user_id = user_id
    @game_member_id = game_member_id
    @check_in_time = check_in_time
    @successful_checks_before = successful_checks_before
    @geo_lat = geo_lat
    @geo_long = geo_long
    mail(:to => "gyms@fitsby.com", :subject => "Checkin from User #{@user_id}")
  end

  def user_deletion(user_id)
    @user_id = user_id
    mail(:to => "team@fitsby.com", :subject => "User #{@user_id} requested a deletion")
  end

  def reset_password_email(user)
    @user = user
    @url  = "http://0.0.0.0:3000/password_resets/#{@user.reset_password_token}/edit"
    mail(:to => user.email,
         :subject => "Your password has been reset")
  end

  def fitsby_daily_report(number_of_users, month, day, year)
    @number_of_users = number_of_users
    @month = month
    @day = day 
    @year = year
    mail(:to => "team@fitsby.com", :subject => "Fitsby daily report")
  end

end


