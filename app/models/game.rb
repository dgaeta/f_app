class Game < ActiveRecord::Base
  
  belongs_to :user
  has_many :game_members, :dependent => :destroy
  #has_many :comments, :dependent => :destroy,  :through => :users
  attr_accessible :creator_id, :duration, :is_private, :wager, :players, :stakes, :game_start_date, :game_end_date, :creator_first_name, 
  :game_initialized, :winning_structure



	GCM.host = 'https://android.googleapis.com/gcm/send'
    # https://android.googleapis.com/gcm/send is default

    GCM.format = :json
    # :json is default and only available at the moment

    GCM.key = "AIzaSyABFztuCfhqCsS_zLzmRv_q-dpDQ80K_gY"
    # this is the apiKey obtained from here https://code.google.com/apis/console/

  	def self.gameHasStartedPush(game_id)
     user_ids = getUserIDSofGame(game_id)
     destination  = []
     count = 0 
     while count < user_ids.count
    	user = User.where(:id => user_ids[count]).first
      unless user.enable_notifications == 'False'
         device = user.device_registration
         destination << device
      end
      count += 1 
     end

     unless destination.empty?
         data = {:key => "Your Fitsby Game #{game_id} has started!", :key2 => ["array", "value"]}
         GCM.send_notification( destination, data, :collapse_key => "game_start", 
      	 :time_to_live => 3600, :delay_while_idle => false )
         puts destination
    	end
  	end

  def self.gameHasEndedPush(game_id)
     user_ids = getUserIDSofGame(game_id)
     registration_ids = []
     user_ids.each do |x|
     	unless x.enable_notifications == 'False'
     	 	device = user.device_registration
         destination << device
      	end
      end

     unless @registration_ids.empty?
        data = {:key => "Your Fitsby Game #{game_id} has started!", :key2 => ["array", "value"]}
        GCM.send_notification( destination, data, :collapse_key => "game_start", 
      	:time_to_live => 3600, :delay_while_idle => false )
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

  	def self.addDayToStartAndEnd(game_id)
    	game = Game.where(:id => game_id).first
    	new_start_date =  (((Time.now.to_i) - 21600 ) +  (24*60*60) )
    	new_end_date = (((Time.now.to_i) - 21600 ) + (game.duration * (24*60*60) ) )
    	game.game_start_date = new_start_date 
    	game.game_end_date = new_end_date
    	game.save 
    end

  def self.findAndReturnFinishedGames(all_init_and_active_Games)
   finished_games =[]

   all_init_and_active_Games.each do |game|    ##check which of the previous games have reached the end date 
     end_date_integer = game.game_end_datre 
     today_integer = Time.now.to_i - 21600
     diff = today_integer - end_date_integer     
     if diff >= 0 
       then
       finished_games << game.id 
      else 
       puts "game #{game.id} is not ready to end"
      end 
    end 
    puts "Game(s) #{finished_games} have finished"
    return finished_games  
  end

  def self.winnerIDs(playerIDs, goal_days)
    winnerGameMemberIDs = []
    playerIDs.each do |id|
      gameMember = GameMember.where(:user_id => id).first
      if gameMember.successful_checks >= goal_days
        winnerGameMemberIDs << gameMember.id
      end
    end
    return winnerGameMemberIDs
  end

  def self.decideAndNotifyResults(playerIDs, number_of_winners, goal_days)
    ###updates user attributes in game.notifyWinner and self.notifyLoser
    count = 0 
    while count < playerIDs.length
      gameMember = playerIDs[count]
      stat = Stat.where(:winners_id => gameMember.user_id).first
      gameMember.active = 0
      gameMember.is_game_over = "TRUE"
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
    user.in_game = 0
    user.save
    stat = Stat.where(:winners_id => user.id)
    stat.games_won += 1
    stat.save
    if wager == 0 
      UserMailer.congratulate_winner_of_free_game(user.email, user.first_name, 
        successful_checks).deliver
    else
      fitsby_percentage = 0.08
      number_of_losers = number_of_players - number_of_winners
      player_cut = ((number_of_losers * wager) * ( 1- fitsby_percentage))/ number_of_winners
      stat.money_won = player_cut
      stat.save
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
    user.in_game = 0 
    user.save
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
