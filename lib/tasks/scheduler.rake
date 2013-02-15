require 'rubygems'
gem 'places'

desc "This task is called by the Heroku scheduler add-on"

task :auto_start_games => :environment do
  puts "Updating games start statuses..."
  @all_games = Game.where(:game_initialized => 0)

  unless @all_games.empty?
    @a = 0 
    @num1 = @all_games.count

    while @a < @num1 do ####start cycling through the games to see what the status is 
		  @game = Game.where(:id => @all_games[@a]).first
		  @start = @game.game_start_date
		  @end = @game.game_end_date
      @time_now = Time.now.to_i - 21420
      @diff = @start - @time_now

	   if @game.players >= 2 and @diff <= 0  ### CASE 1 = has 2 players and start date is here
	      then 
        @game.game_initialized = 1 
        
        if @game.players <= 3   #### checks to see if the stucture is 3 winners but less than 3 users 
          then 
          @game.winning_structure = 1 
          @game.was_recently_initiated = 1
          @game.save 
          else
          @game.save 
        end  
	     
        ### Make the comment that the game is ready to start
        @comment = Comment.new(:from_game_id => @game.id , :from_user_id => 101,  :email => "team@fitsby.com",
        :bold => "TRUE", :first_name => "ANNOUNCEMENT",  :last_name => " " , :message => "The game has started!",
        :stamp => Time.now)
        @comment.email = "team@fitsby.com"
        @comment.from_user_id = 101
        @comment.bold = "TRUE"
        @comment.save
        ### End comment 

        ########### game start push begin ##############
        notification = Gcm::Notification.new
        device = Gcm::Device.all.first
        notification.device = device
        notification.collapse_key = "game_start"
        notification.delay_while_idle = true
        
        @b = 0 
        @num2 = @game.players
        @registration_ids = []
        user_ids = GameMember.where(:game_id => @game.id).pluck(:user_id)
        
        while @b < @num2 do ### Gather registration ids 
          user = User.find(user_ids[@b])
          if (user.enable_notifications == "FALSE") or (user.device_id == "0")
            @b += 1 
            else
            device = Gcm::Device.find(user.device_id)
            @registration_ids << device.registration_id
            @b += 1 
          end
        end
        
        notification.data = {:registration_ids => @registration_ids,
        :data => {:message_text => "Your Fitsby Game #{@game.id} has started!                              "}}
        unless @registration_ids.empty?
          notification.save
        end
    
        ########### End of push notifications ###############
        ########### make game members active  ###############
        @c = 0 
        @num3 = @game.players
        @game_members = GameMember.where(:game_id => @game.id)
        @time_now = Time.now.to_i - 21420
while @c < @num3 do 
          @member = @game_members[@c]
          @member.active = 1
          @member.activated_at = @time_now
          @member.save 
          @c += 1 
        end 
        
        ########## end make member active  #################
	      puts "started game #{@game.id}"
	    

      elsif @game.players >= 2 and @diff > 0
	      @game.game_initialized = 0
	      puts "game #{@game.id} time hasnt passed to start, but has enough players"
	   

     elsif @game.players < 2 and @diff <= 0 
	      @new_start_date = @start +  (24*60*60)
	      @new_end_date = @end + (1*24*60*60)
	      @game.game_start_date = @new_start_date 
	      @game.game_end_date = @new_end_date
	      @game.save 
        @comment = Comment.new(:from_game_id => @game.id, :email => "team@fitsby.com", :from_user_id => 101, :first_name => "ANNOUNCEMENT", 
        :last_name => " " , :bold => "TRUE", 
        :message => "The game start date has been pushed forward 1 day! (Need at least 2 players).", 
        :stamp => Time.now)
        @comment.email = "team@fitsby.com"
        @comment.from_user_id = 101
        @comment.bold = "TRUE"
        @comment.save
        puts "game #{@game.id} not enough players at start date, added 1 more days to start date"
	   

     elsif @game.players < 2 and @diff > 0
	     @game.game_initialized = 0
	     puts "game #{@game.id} does not have enough players and time hasnt passed"
     end
	   
      @a += 1 ### Move on to next game
	  end
  end
  puts "done."
end













task :add_gyms_to_google => :environment do
      @client = Places::Client.new(:api_key => 'AIzaSyABFztuCfhqCsS_zLzmRv_q-dpDQ80K_gY')
      @unadded = Decidedlocation.where(:added_to_google => 0)
      
      unless @unadded.empty? 
       @number_of_unadded = @unadded.count

       @a = 0 
       @num = @number_of_unadded

       while @a < @num do
        @gym = @unadded[@a]
        @add = @client.add(:lat => @gym.geo_lat , :lng => @gym.geo_long, :accuracy => 50,
         :name => @gym.gym_name, :types => "gym")
        @gym.added_to_google = 1 
        @gym.save
        puts "added #{@gym.gym_name} to google api."
        @a += 1
       end 
    end
end  












task :auto_end_games => :environment do
puts "Updating game end statuses..."
  @all_games = Game.where(:game_initialized => 1).pluck(:id) #get all games 
 
  @a = 0 
  @num1 = @all_games.count 
  @active_games = []

  while @a < @num1 do         # get all games that are currently alive and allowing check ins (initialized)
    @game = Game.find(@all_games[@a])
    if @game.game_active == 1 
     then 
     @active_games << @all_games[@a]
     @a += 1 
     else 
     @a += 1 
    end
  end 
  puts "Game(s) #{@active_games} are active and initialized"


  @b = 0 
  @num2 =  @active_games.count
  @finished_games = []

  while @b < @num2       ##check which of the previous games have reached the end date 
   @game = Game.where(:id => @active_games[@b]).first
   @end_date_integer = @game.game_end_date 
   @today_integer = Time.now.to_i - 21600
   @diff = @today_integer - @end_date_integer

   if @diff >= 0 
     then @finished_games << @game.id 
     @b += 1
     else 
     puts "game #{@game.id} is not ready to end"
     @b += 1 
    end 
  end 
  puts "Game(s) #{@finished_games} have finished"

  unless @finished_games.empty?
    @c = 0 
    @num3 = @finished_games.count

    while @c < @num3 
      @game = Game.find(@finished_games[@c])
      #######1st_step add up total time at gym for all players #######
      @players = GameMember.where(:game_id => @game.id)
      number_of_players = @players.count  
   
      @players = GameMember.where(:game_id => @game.id)
   
      @f = 0
      @num6 = number_of_players

      while @f < @num6  do ####gives everyone a loss (changes the winner's losses later)
        @game_member = @players[@f]
        @goal_days = @game.goal_days
        @stat = Stat.where(:winners_id => @game_member.user_id).first

        if @game_member.successful_checks >= @goal_days
          @stat.games_won += 1 
          @stat.games_played += 1 
          @stat.save

         unless @game.wager == 0 
            game_id = @game_member.game_id
            user = User.where(:id => @game_member.user_id).first_name
            winner_email = user.email 
            winner_first_name = user.first_name
            winner_user_id = user.id 
            player_cut = (@game.stakes * 0.92) / @game.players
            fitsby_percentage = 0.08
            fitsby_money_won = (@game.stakes * @fitsby_percentage) + (0.50 * number_of_players)
            total_money_processed = (@game.stakes + (@game.players * 0.50))
            UserMailer.congratulate_winner_of_game(winner_email, winner_first_name, game_id, player_cut).deliver ###TODO TODO TODO TODO TODO fix this mailer 
            UserMailer.email_ourselves_to_pay_winner_of_game(game_id, winner_first_name, winner_email, winner_user_id, 
            player_cut, fitsby_money_won, total_money_processed )
          else 
            user = User.where(:id => @game_member.user_id).first_name
            winner_email = user.email 
            winner_first_name = user.first_name
            UserMailer.congratulate_winner_of_free_game(winner_email, winner_first_name).deliver ###TODO TODO TODO TODO TODO fix this mailer 
          end
          @f += 1 
        else 
          @stat.losses += 1 
          @stat.games_played += 1 
          @stat.save

          unless @game.wager == 0 
            goal_days = @goal_days
            money_lost = @game.wager
            game_id = @game_member.game_id
            user = User.where(:id => @game_member.user_id).first_name
            loser_email = user.email 
            loser_first_name = user.first_name
            loser_user_id = user.id 
            UserMailer.notify_loser(money_lost, game_id, loser_email, loser_first_name, loser_user_id, loser_checkins, goal_days).deliver ###TODO TODO TODO TODO TODO fix this mailer 

            Stripe::Charge.create(
            :amount => ((@game.wager * 100) + 50), # (example: 1000 is $10)
            :currency => "usd",
            :customer => user.customer_id)

          else 
            goal_days = @goal_days
            money_lost = 0
            loser_checkins = @game_member.successful_checks
            game_id = @game_member.game_id
            user = User.where(:id => @game_member.user_id).first_name
            loser_email = user.email 
            loser_first_name = user.first_name
            loser_user_id = user.id 
            UserMailer.notify_loser(money_lost, game_id, loser_email, loser_first_name, loser_user_id, loser_checkins, goal_days).deliver  
          end
          @f += 1 
        end 
    
        ############# Start the PUSH notification ##########################################
        notification = Gcm::Notification.new
        notification.device = Gcm::Device.all.first
        notification.collapse_key = "game_start"
        notification.delay_while_idle = true
      
        @g = 0 
        @num8 = @game.players
        @registration_ids = []
    
        while @g < @num8 do 
          user_ids = GameMember.where(:game_id => @game.id).pluck(:user_id)
          user = User.find(user_ids[@g])
          if (user.enable_notifications == "FALSE") or (user.device_id == "0")
            @g += 1 
          else
            device = Gcm::Device.find(user.device_id)
            @registration_ids << device.registration_id
            @g += 1 
          end
        end
    
        notification.data = {:registration_ids => @registration_ids,
        :data => {:message_text => "Your Fitsby Game #{@game.id} has ended!                                   "}}
        unless @registration_ids.empty?
          notification.save
        end
        ############ PUSH END ###########################################
        @game.game_active = 0
        @game.is_private = "TRUE"
        @game.save
        @d += 1
      end
    end
  end
end   



task :make_games_private_1_day_after => :environment do 
  puts "Making games private..."
  @all_games = Game.where(:was_recently_initiated => 1).pluck(:id) #get all games that were recently initialized

  #check to see if they have more than 1 player

  @placeHolder = 0 
  @numberOfRecentlyInitializedGames = @all_games.count
  @gamesThatNeedToBePrivatized = Array.new

  unless @all_games.empty?
    while @placeHolder < @numberOfRecentlyInitializedGames do        
      @game = Game.where(:id => @all_games[@placeHolder]).first
      if @game.players > 1 
        @gamesThatNeedToBePrivatized << @game.id
        @placeHolder += 1
      else 
        @placeHolder += 1
      end
    end 


    @a = 0 
    @num1 = @gamesThatNeedToBePrivatized.count 

    unless @gamesThatNeedToBePrivatized.empty?
      while @a < @num1 do        
        @game = Game.find(@gamesThatNeedToBePrivatized[@a])
        @game.is_private = "TRUE"
        @game.was_recently_initiated = 0 
        @game.save
        puts "made game #{@game.id} private"
        @a += 1
      end 
    end
  end  
end



task :send_notification_to_inactive_game_members => :environment do 
  puts "Sending notifications to inactive members..."
  @all_game_members = GameMember.where(:active => "1", :successful_checks => "0")

  unless @all_game_members.empty?
    @a = 0 
    @num = @all_game_members.count 
    @time_now = Time.now.to_i - 21420

    while @a < @num do 
      @selected_game_member = GameMember.where(:id => @all_game_members[@a].id).first
      @last_activity = @selected_game_member.activated_at
 
      if ((@time_now - @last_activity) >= 172800) and ((@time_now - @last_activity)   <= 259200)
      then 
        puts "game member #{@selected_game_member.id} has been inactive for 2 days"
        @user = User.where(:id => @selected_game_member.user_id).first
        unless ((@user.enable_notifications == "FALSE") or (@user.device_id == "0" ))

          notification = Gcm::Notification.new
          notification.device = Gcm::Device.all.first
          notification.collapse_key = "no_check_in"
          notification.delay_while_idle = true
          @user = User.where(:id => @selected_game_member.user_id).first
          device = Gcm::Device.find(@user.device_id)
          @registration_id = device.registration_id   
          notification.data = {:registration_ids => [@registration_id],
          :data => {:message_text => "Hey! You haven\'t checked in yet."}}
          unless @registration_id.empty?
            notification.save
          end
        end
        @a += 1 
       else 
         puts "game member #{@selected_game_member.id} has been inactive but not for 2 days"
        @a += 1
      end 
    end 
  end
end




 task :end_games_now => :environment do 
    @allGames = Game.all 

    @counter = 0 
    @numberOfGames = @allGames.count
    @timeNow = Time.now.to_i - 21420

    while @counter < @numberOfGames do 
      @selectedGame = @allGames[@counter]
      @gameEndDate = @selectedGame.game_end_date 
      if (@timeNow > @gameEndDate)
        @selectedGame.game_active = 0
        @selectedGame.save
        @counter += 1 
        puts "game #{@selectedGame.id} status changed to 0"
      else 
        @counter += 1 
      end
    end
  end 


  task :make_games_private_now => :environment do
    puts "making games private..."
    @allGames = Game.where(:is_private => "TRUE").pluck(:id)

    unless @all_games.empty?
      @counter = 0 
      @numberOfGames = @allGames.count
      @timeNow = Time.now.to_i - 21420
      @timeNow = @timeNow.to_i

      while @counter < @numberOfGames do 
        @game = @allGames[@counter]
        if @game.game_start_date < @timeNow
          @game.is_private = "TRUE"
          @game.save
          @counter += 1 
        else 
          @counter += 1 
        end 
      end
    end
  end












