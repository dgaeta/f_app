class Game < ActiveRecord::Base
  
  belongs_to :user
  has_many :game_members, :dependent => :destroy
  #has_many :comments, :dependent => :destroy,  :through => :users
  attr_accessible :creator_id, :duration, :is_private, :wager, :players, :stakes, :game_start_date, :game_end_date, :creator_first_name, 
  :game_initialized, :winning_structure

  def self.gameHasStartedPush(game_id)
    user_ids = getUserIDSofGame(game_id)
    registration_ids = []
    count = 0 
    while count < user_ids.count
    	user = User.where(:id => user_ids[count]).first
      unless user.enable_notifications == 'False'
        device = Gcm::Device.find(user.device_id)
        registration_ids << device.registration_id 
      end
      count += 1 
    end

    unless @registration_ids.length == 0 
      notification = Gcm::Notification.new
      device = Gcm::Device.all.first
      notification.device = device
      notification.collapse_key = "game_start"
      notification.delay_while_idle = true
      notification.data = {:registration_ids => registration_ids,
      :data => {:message_text => "Your Fitsby Game #{game_id} has started!                              "}}  
      notification.save
    end
    puts registration_ids
  end

  def self.gameHasEndedPush(game_id)
    user_ids = getUserIDSofGame(game_id)
    registration_ids = []
    user_ids.each do |x|
      unless x.push_enabled == 'False'
        device = Gcm::Device.find(x.device_id)
        @registration_ids << device.registration_id 
      end
    end

    unless @registration_ids.empty?
      notification = Gcm::Notification.new
      device = Gcm::Device.all.first
      notification.device = device
      notification.collapse_key = "game_start"
      notification.delay_while_idle = true
      notification.data = {:registration_ids => @registration_ids,
      :data => {:message_text => "Your Fitsby Game #{game.id} has ended!                              "}}  
      notification.save
    end
    puts @registration_ids  
  end

  def self.getUserIDSofGame(game_id)
    gameMembers = GameMember.where(:game_id => game_id)
    count = 0 
    while count < gameMembers.count
      gameMembers[count].active = 1
      gameMembers[count].activated_at = Time.now.to_i
      gameMembers[count].save 
      count += 1
    end
    arrayOfUserIds = GameMember.where(:game_id => game_id).pluck(:user_id)
    puts arrayOfUserIds
    return arrayOfUserIds  
  end

  def self.addDayToStartandEnd(game_id)
    @game = Game.where(:id => game_id).first
    @start = @game.game_start_date
    @new_start_date = @start +  (24*60*60)
    @new_end_date = @end + (1*24*60*60)
    @game.game_start_date = @new_start_date 
    @game.game_end_date = @new_end_date
    @game.save 
  end

  def self.findAndReturnFinishedGames(all_init_and_active_Games)
   count = 0 
    while count < all_init_and_active_Games.length do     ##check which of the previous games have reached the end date 
     game = Game.where(:id => all_init_and_active_Games[count]).first
     end_date_integer = game.game_end_date 
     today_integer = Time.now.to_i - 21600
     diff = today_integer - end_date_integer

     finished_games =[]
     if diff >= 0 
       then
       finished_games << game.id 
       count += 1
      else 
       puts "game #{game.id} is not ready to end"
       count += 1 
      end 
    end 
    puts "Game(s) #{finished_games} have finished"
    return finished_games  
  end

  def self.winnerIDs(playerIDs, goal_days)
    winnerGameMemberIDs = []
    if gameMember.successful_checks >= goal_days
      winnerGameMemberIDs << gameMember.id
    end
    return winnerGameMemberIDs
  end

  def self.decideAndNotifyResults(playerIDs, number_of_winners, goal_days)
    count = 0 
    while count < playerIDs.length
      gameMember = playerIDs[count]
      stat = Stat.where(:winners_id => gameMember.user_id).first
      gameMember.active = 0
      gameMember.save
      game = Game.where(:id => gameMember.game_id)
      if gameMember.successful_checks >= goal_days
        stat.games_won += 1 
        stat.games_played += 1 
        stat.save
        Game.notifyWinner(gameMember.game_id, gameMember.user_id, number_of_winners,
         game.wager, game.players, gameMember.successful_checks)
      else 
        number_of_losers = game.players - number_of_winners
        Game.notifyLoser(gameMember.game_id, gameMember.user_id, number_of_losers)
      end
    end
  end

  def self.notifyWinner(game_id, user_id, number_of_winners, wager, num_of_players, successful_checks)
    user = User.where(:id => user_id).first
    if wager == 0 
      UserMailer.congratulate_winner_of_free_game(user.email, user.first_name, 
        successful_checks).deliver
    else
      fitsby_percentage = 0.08
      number_of_losers = number_of_players - number_of_winners
      player_cut = ((number_of_losers * wager) * ( 1- fitsby_percentage))/ number_of_winners
      fitsby_money_won = ((number_of_losers * wager) * fitsby_percentage) + (0.50 * number_of_losers)
      total_money_processed = ((number_of_losers * wager) + (number_of_losers * 0.50))
      UserMailer.congratulate_winner_of_game(user.email, user.first_name, game_id, player_cut).deliver ###TODO TODO TODO TODO TODO fix this mailer 
      UserMailer.email_ourselves_to_pay_winner_of_game(game_id, user.first_name, user.email, user.id, 
      player_cut, fitsby_money_won, total_money_processed).deliver
    end
  end


  def self.notifyLoser(game_id, user_id, number_of_losers)
    game = Game.where(:id => game_id)
    user = User.where(:id => user_id).first
    stat = Stat.where(:winners_id => user.id)
    stat.losses += 1 
    stat.games_played += 1 
    stat.save
    loser_checkins = GameMember.where(user_id => user_id, :game_id => game_id).pluck(:successful_checks)
    
    if game.wager == 0          
      loser_email = user.email 
      loser_first_name = user.first_name
      loser_user_id = user.id 
      UserMailer.notify_loser_of_free_game(game.id, loser_email, loser_first_name, loser_user_id, loser_checkins).deliver  
    else
      money_lost = game.wager
      loser_email = user.email 
      loser_first_name = user.first_name
      loser_user_id = user.id 
      UserMailer.notify_loser_of_paid_game(money_lost, game.id, loser_email, loser_first_name, loser_user_id, 
        loser_checkins).deliver ###TODO TODO TODO TODO TODO fix this mailer 

      Stripe::Charge.create(
      :amount => ((game.wager * 100) + 50), # (example: 1000 is $10)
      :currency => "usd",
      :customer => user.customer_id)
    end
  end


end
