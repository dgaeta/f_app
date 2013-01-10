class UserMailer < ActionMailer::Base
  default from: "Fitsby Team <team@fitsby.com>"

   def welcome_email(user) ##make nice view
    @user = user
    @url  = "http://fitsby.com"
    mail(:to => user.email, :subject => "Welcome to Fitsby, #{@user.first_name}!")
  end

  def congratulate_winner1(winner1, winner1_money_won) ##make views
    @user = winner1
    @winner1_money_won = sprintf("%.2f", winner1_money_won)
    @url  = "http://fitsby.com"
    mail(:to => @user.email, :subject => "Congrats #{@user.first_name}, you earned $#{@winner1_money_won}!")
  end

  def congratulate_winner2(winner2, winner2_money_won) ##make views
    @user = winner2
    @winner2_money_won = sprintf("%.2f", winner2_money_won)
    @url  = "http://fitsby.com"
    mail(:to => @user.email, :subject => "Congrats #{@user.first_name}, you earned $#{@winner2_money_won}!")
  end

  def congratulate_winner3(winner3, winner3_money_won) ##make views
    @user = winner3
    @winner3_money_won = sprintf("%.2f", winner3_money_won)
    @url  = "http://fitsby.com"
    mail(:to => @user.email, :subject => "Congrats #{@user.first_name}, you earned $#{@winner3_money_won}!")
  end

  def notify_loser(user, loser_checkins, place)   ##make view
    @user = user
    @loser_checkins = loser_checkins
    @place = place 
    @url  = "http://fitsby.com"
    mail(:to => user.email, :subject => "Oh no #{@user.first_name}! You just lost a game of Fitsby")
  end

  def email_ourselves_to_pay_3_winners(game_id, winner1, winner1_money_won, winner2, winner2_money_won, 
         winner3, winner3_money_won, fitsby_money_won, total_money_processed)   ##make view
    @game_id = @game_info.id
    @winner1 = winner1
    @winner1_money_won = sprintf("%.2f", winner1_money_won)
    @winner2 = winner2
    @winner2_money_won = sprintf("%.2f", winner2_money_won)
    @winner3 = winner3
    @winner3_money_won = sprintf("%.2f", winner3_money_won)
    @fitsby_money_won = sprintf("%.2f", fitsby_money_won)
    @total_money_processed = total_money_processed
    @url  = "http://fitsby.com"
    mail(:to => "payments@fitsby.com", :subject => "")
  end

  def email_ourselves_to_pay_1_winner(game_id, winner1, winner1_money_won, fitsby_money_won, 
  total_amount_charged_to_losers, total_money_processed)   ##make view
    @game_id = game_id
    @winner1 = winner1
    @winner1_money_won = sprintf("%.2f", winner1_money_won)
    @fitsby_money_won = sprintf("%.2f", fitsby_money_won)
    @total_amount_charged_to_losers = total_amount_charged_to_losers
    @total_money_processed = total_money_processed
    @url  = "http://fitsby.com"
    mail(:to => "payments@fitsby.com", :subject => "Pay winner")
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

end


