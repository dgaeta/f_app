class UserMailer < ActionMailer::Base
  default from: "Fitsby Team <team@fitsby.com>"

   def welcome_email(user) ##make nice view
    @user = user
    @url  = "http://example.com/login"
    mail(:to => user.email, :subject => "Welcome to My Awesome Site")
  end

  def congratulate_winner1(winner1, winner1_money_won) ##make views
    @user = winner1
    @winner1_money_won = winner1_money_won
    @url  = "http://example.com/login"
    mail(:to => @user.email, :subject => "Congrats, you just won $#{@winner1_money_won}")
  end

  def congratulate_winner2(winner2, winner2_money_won) ##make views
    @user = winner2
    @winner2_money_won = winner2_money_won
    @url  = "http://example.com/login"
    mail(:to => @user.email, :subject => "Congrats, you just won $#{@winner2_money_won}")
  end

  def congratulate_winner3(winner3, winner3_money_won) ##make views
    @user = winner3
    @winner3_money_won = winner3_money_won
    @url  = "http://example.com/login"
    mail(:to => @user.email, :subject => "Congrats, you just won $#{@winner3_money_won}")
  end

  def notify_loser(user)   ##make view
    @user = user
    @url  = "http://example.com/login"
    mail(:to => user.email, :subject => "Sorry Dude.")
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
    @url  = "http://example.com/login"
    mail(:to => "payments@fitsby.com", :subject => "You owe people money!")
  end

end
