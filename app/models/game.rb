class Game < ActiveRecord::Base
  require "stripe"
  
  belongs_to :user
  has_many :game_members, :dependent => :destroy
  #has_many :comments, :dependent => :destroy,  :through => :users
  attr_accessible :creator_id, :duration, :is_private, :wager, :players, :stakes, :game_start_date, :game_end_date, :creator_first_name, 
  :game_initialized, :winning_structure
  has_many :comments, as: :commentable
  has_many :notifications, as: :notifiable




  	def self.gameHasStartedPush(game_id)
     user_ids = getUserIDSofGame(game_id)
     destination  = []
     count = 0 
     while count < user_ids.count
    	user = User.where(:id => user_ids[count]).first
      unless (user.enable_notifications == 'False' || user.device_registered == "FALSE")
         device = user.gcm_registration_id
         destination << device
         puts "sent to user <% user.id %>"
      end
      count += 1 
     end

     unless destination.empty?
      notification = {
        :schedule_for => [1],
        :apids => destination,
        :android => {:alert => "Your Fitsby Game #{game_id} has started!", :collapse_key => "game_start"}
      }
         
      #sUrbanairship.push(notification)   
      end
  	end

  def self.gameHasEndedPush(game_id)
     user_ids = getUserIDSofGame(game_id)
     destination = []
     user_ids.each do |id|
      user = User.where(:id => id).first
     	unless (user.enable_notifications == 'False' || user.device_registered == "FALSE")
     	 	 device = user.gcm_registration_id
         destination << device
         puts "sent to user <% user.id %>"
      	end

      end

     unless destination.empty?
      notification = {
        :apids => destination,
        :android => {:alert => "Your Fitsby Game #{game_id} has ended!", :collapse_key => "game_start"}
      }
         
      #Urbanairship.push(notification)   
      end 
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
     end_date_integer = game.game_end_date 
     today_integer = (Time.now.to_i - 21600)
     diff = (today_integer - end_date_integer)     
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

  def self.countWinnerIDs(playerIDs, goal_days)
    winnerGameMemberIDs = []
    playerIDs.each do |gameMember|
      if gameMember.successful_checks >= goal_days
        winnerGameMemberIDs << gameMember.id
      end
    end
    if winnerGameMemberIDs.length == 0 
      return 0 
    else 
      return winnerGameMemberIDs.length
    end
  end

  def self.decideAndNotifyResults(playerIDs, number_of_winners, goal_days)
    @number_of_winners = number_of_winners
    ###updates user attributes in game.notifyWinner and self.notifyLoser
    count = 0 
    while count < playerIDs.length
      gameMember = playerIDs[count]
      stat = Stat.where(:winners_id => gameMember.user_id).first
      gameMember.active = 0
      gameMember.is_game_over = "TRUE"
      gameMember.save
      game = Game.where(:id => gameMember.game_id).first
      if gameMember.successful_checks >= goal_days
        stat.games_won += 1 
        stat.games_played += 1 
        stat.save
        Game.notifyWinner(gameMember.game_id, gameMember.user_id, @number_of_winners,
         game.wager, game.players, gameMember.successful_checks)
      else 
        number_of_losers = (game.players - @number_of_winners)
        Game.notifyLoser(gameMember.game_id, gameMember.user_id, number_of_losers, gameMember.successful_checks)
      end
      count += 1 
    end
  end

  def self.notifyWinner(game_id, user_id, number_of_winners, wager, num_of_players, successful_checks)
    user = User.where(:id => user_id).first
    user.in_game = 0   ## 0 means false
    user.save
    stat = Stat.where(:winners_id => user.id).first
    stat.games_won += 1
    stat.save
    @notification = Notification.new
    @notification.message = "Hey, " + user.first_name + " you won your game!"
    @notification.content = "Game won"
    @notification.game_id = game.id      
    @notification.notifiable_id = user.id
    @notification.notifiable_type = 'User'
    @notification.save  
    if wager == 0 
      Notifier.congratulate_winner_of_free_game(user.email, user.first_name, 
        successful_checks).deliver
    else
      fitsby_percentage = 0.08
      number_of_losers = (num_of_players - number_of_winners)
      player_cut = ((number_of_losers * wager) * ( 1- fitsby_percentage))/ number_of_winners
      stat.money_earned += player_cut
      stat.save
      fitsby_money_won = ((number_of_losers * wager) * fitsby_percentage) + (0.50 * number_of_losers)
      total_money_processed = ((number_of_losers * wager) + (number_of_losers * 0.50))
      Notifier.congratulate_winner_of_game(user.email, user.first_name, game_id, player_cut).deliver ###TODO TODO TODO TODO TODO fix this mailer 
      Notifier.email_ourselves_to_pay_winner_of_game(game_id, user.first_name, user.email, user.id, 
      player_cut, fitsby_money_won, total_money_processed).deliver
    end
  end


  def self.notifyLoser(game_id, user_id, number_of_losers, loser_checkins)
    Stripe.api_key = "sk_0G8Utv86sXeIUY4EO6fif1hAypeDE"
    game = Game.where(:id =>  game_id).first
    user = User.where(:id => user_id).first
    game_member = user.game_members.where(:game_id => game_id).first
    game_member.active = 0 
    game_member.save
    stat = Stat.where(:winners_id => user_id).first
    stat.losses += 1 
    stat.games_played += 1 
    stat.save

    @notification = Notification.new
    @notification.message = "Sorry, " + user.first_name + " you lost your game"
    @notification.content = "Game loss"
    @notification.game_id = game.id      
    @notification.notifiable_id = user.id
    @notification.notifiable_type = 'User'
    @notification.save  
 
    
    if game.wager == 0          
      loser_email = user.email 
      loser_first_name = user.first_name
      loser_user_id = user.id 
      Notifier.notify_loser_of_free_game(game.id, loser_email, loser_first_name, loser_user_id, loser_checkins).deliver
    else
      unless game_member.was_charged
        money_lost = game.wager
        loser_email = user.email 
        loser_first_name = user.first_name
        loser_user_id = user.id 
        Notifier.notify_loser_of_paid_game(money_lost, game.id, loser_email, loser_first_name, loser_user_id, 
          loser_checkins).deliver ###TODO TODO TODO TODO TODO fix this mailer 

        Stripe::Charge.create(
        :amount => ((game.wager * 100) + 50), # (example: 1000 is $10)
        :currency => "usd",
        :customer => user.customer_id)

        game_member.was_charged = "TRUE"
        game_member.save

        #rescue Stripe::CardError => e
         # flash[:error] = e.message
         # redirect_to charges_path
         # Notifier.stripe_create_customer_error(user.id, game.id, user.email, game.wager, user.customer_id, e.message).deliver
         # card_error_json = { :status => "error charging customer"} 
         # render(json: JSON.pretty_generate(card_error_json))
      end
    end
  end

  def self.gameLoadPlayers
    game = Game.where(:id => game_id).first
    
    players = GameMember.includes(:user).where(:game_id => game_id).order("successful_checks DESC")
    player_list = players.map do |member|
      {:user_id => member.user.id,
      :first_name => member.user.first_name,
      :successful_checks => member.successful_checks, 
      :email => member.user.email}
    end   
  end

  def self.auto_start_games
    all_Active_Games = Game.where(:game_active => 1, :game_initialized => 0)
    started_games = []

    unless all_Active_Games.length == 0
      all_Active_Games.each do |game|
        if game.players >= 2 
          game.winning_structure = 1 if game.players < 3
          #Comment.gameStartComment(game.id)
          Game.gameHasStartedPush(game) #### updates user events here 
          GameMember.activatePlayers(game.id)
          game.game_start_date = (Time.now.to_i - 21600)
          game.game_end_date = (((Time.now.to_i) -21600) + (game.duration * (24*60*60)))
          game.game_initialized = 1 
          game.was_recently_initiated = 1
          started_games << game.id
          game.save
          game_members_in_game = GameMember.where(:game_id => game.id)
          game_members_in_game.each do |gm|
            @notification = Notification.new
            @notification.content = "Game started"
            @notification.message = "Your Game has started"
            @notification.notifiable_id = gm.user_id
            @notification.notifiable_type = 'User'
            @notification.game_id = game.id
            @notification.save
          end
        else 
          Game.addDayToStartAndEnd(game.id)
          #Comment.gamePostponedComment(game.id)
        end
      end
    end
    puts "started games #{started_games}"
  end

end
