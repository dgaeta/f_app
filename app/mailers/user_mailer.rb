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
    mail(:to => @user.email, :subject => "Congrats #{@user.first_name}, you earned $#{@winner1_money_won}")
  end

  def congratulate_winner2(winner2, winner2_money_won) ##make views
    @user = winner2
    @winner2_money_won = sprintf("%.2f", winner2_money_won)
    @url  = "http://fitsby.com"
    mail(:to => @user.email, :subject => "Congrats #{@user.first_name}, you earned $#{@winner2_money_won}")
  end

  def congratulate_winner3(winner3, winner3_money_won) ##make views
    @user = winner3
    @winner3_money_won = sprintf("%.2f", winner3_money_won)
    @url  = "http://fitsby.com"
    mail(:to => @user.email, :subject => "Congrats #{@user.first_name}, you earned $#{@winner3_money_won}")
  end

  def notify_loser(user, amount_charged, loser_checkins)   ##make view
    @user = user
    amount_charged = amount_charged / 100
    @amount_charged = sprintf("%.2f", amount_charged)
    @loser_checkins = loser_checkins
    @url  = "http://fitsby.com"
    mail(:to => user.email, :subject => "Oh no #{@user.first_name}! You just lost a game of Fitsby")
  end

  def email_ourselves_to_pay_winners(winner1, winner1_money_won, winner2, winner2_money_won, 
         winner3, winner3_money_won, fitsby_money_won)   ##make view
    @winner1 = winner1
    @winner1_money_won = winner1_money_won
    @winner2 = winner2
    @winner2_money_won = winner2_money_won
    @winner3 = winner3
    @winner3_money_won = winner3_money_won
    @fitsby_money_won = fitsby_money_won
    @url  = "http://fitsby.com"
    mail(:to => "payments@fitsby.com", :subject => "You owe people money!")
  end

end
