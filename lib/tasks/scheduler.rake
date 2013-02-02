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
        notification.collapse_key = "Games"
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
















task :auto_end_1_games => :environment do
puts "Updating games with 1 winner end statuses..."
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
  @num2 = @active_games.count
  @games_with_1_structure = []

  while @b < @num2 do    #get all games with winning structure 1 
   @game = Game.find(@active_games[@b])
    if  @game.winning_structure == 1 
    then
     @games_with_1_structure << @game.id
     @b += 1 
    else 
     @b += 1
    end
  end
  puts "Game(s) #{@games_with_1_structure} have winning struc 1"

  @c = 0 
  @num3 =  @games_with_1_structure.count
  @finished_games = []

  while @c < @num3       ##check which of the previous games have reached the end date 
   @game = Game.where(:id => @games_with_1_structure[@c]).first
   @end_date_integer = @game.game_end_date 
   @today_integer = Time.now.to_i - 21600
   @diff = @today_integer - @end_date_integer

   if @diff >= 0 
    then @finished_games << @game.id 
    @c += 1
  else 
    puts "game #{@game.id} with winning struct. 1 is not ready to end"
    @c += 1 
   end 
  end 
  puts "Game(s) #{@finished_games} have finished"

  unless @finished_games.empty?
    @d = 0 
    @num4 = @finished_games.count

    while @d < @num4 do    
      @game = Game.find(@finished_games[@d])
      #######1st_step add up total time at gym for all players #######
      @game.game_active = 0 
      @game.save 

      @players = GameMember.where(:game_id => @game.id) ##gets all players and assigns to array
      number_of_players = @players.count 

      @e = 0 
      @num5 = number_of_players

      while @e < @num5 do   ####assigns the stats to the users 
        @game_member = @players[@e]
        @game_member.active = 0 
        checks = @game_member.successful_checks * 1000000
        total_minutes = @game_member.total_minutes_at_gym / 60 
        checks_and_minutes = checks + total_minutes
        @game_member.end_game_checks_evaluation = checks_and_minutes
        @game_member.save
        @e += 1
      end
      ###### end adding up total time at gym ###########

      ###### 2nd_step order the players by place now that we incorporated the minutes########
      @players = GameMember.where(:game_id => @game.id).order("end_game_checks_evaluation DESC")
   
      @f = 0
      @num6 = number_of_players 

      while @f < @num6  do  ###gives everyone a loss (we append the winners losses later)
        @game_member = @players[@f]
        @stat = Stat.where(:winners_id => @game_member.user_id).first
        @stat.losses += 1
        @stat.save
        @f +=1
      end
      ###### end ordering by place #####################

      ###### notify the losers that they lost ######################
      @losers = 1
      @num7 = number_of_players

      while @losers < @num7  do
        game_member = @players[@losers]
        user = User.find(game_member.user_id)
        place = @losers + 1 
        loser_checkins = game_member.successful_checks
        UserMailer.notify_loser(user, loser_checkins, place).deliver
        @losers +=1
      end

      ####### PAY THE WINNER
      winner1 = User.find(@players[0].user_id)
      first = GameMember.where(:user_id => winner1.id, :game_id => @game.id).first
      first.final_standing = 1
      first.save
      first = Stat.where(:winners_id => winner1).first
      first.losses -= 1
      first.first_place_finishes += 1
      first.save

      unless @game.wager == 0 
        ####### define the payout amounts
        @first_place_percentage = 0.92
        @fitsby_percentage = 0.08

        winner1_money_won = (@game.stakes  * @first_place_percentage)
        total_money_processed = (@game.stakes + (@game.players * 0.50))
        total_amount_charged_to_losers = (@game.stakes + ((@game.players - 1) * 0.50))
        fitsby_money_won = (@game.stakes * @fitsby_percentage) + (0.50 * @number_of_players)
        UserMailer.congratulate_winner1(winner1, winner1_money_won).deliver
        game_id = @game.id
        UserMailer.email_ourselves_to_pay_1_winner(game_id, winner1, winner1_money_won, fitsby_money_won, 
        total_amount_charged_to_losers,total_money_processed).deliver 
        else 
        winner1_money_won = 0 
        UserMailer.congratulate_winner1(winner1, winner1_money_won).deliver
        total_money_processed = 0
        total_amount_charged_to_losers = 0 
        fitsby_money_won = 0
        game_id = @game.id
        UserMailer.email_ourselves_to_pay_1_winner(game_id, winner1, winner1_money_won, fitsby_money_won, 
        total_amount_charged_to_losers, total_money_processed).deliver 
      end
    
      ###### inactivate the game, put status, move to next game #########
      @game.game_active = 0
      @game.is_private = "TRUE"
      @game.save
    
      ########### game start push begin ##############
      notification = Gcm::Notification.new
      notification.device = Gcm::Device.all.first
      notification.collapse_key = "Games"
      notification.delay_while_idle = true
      
      @g = 0 
      @num8 = @game.players
      @registration_ids = []
    
      while @g < @num8 do #begin cycle to get registration id from each user 
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
      :data => {:message_text => "Your Fitsby Game #{@game.id} has ended!                                     "}}
      unless @registration_ids.empty?
        notification.save
      end
      ########### game start push ends ###############
    
      puts "sent out mail and charges for game #{@game.id}"
      @d += 1     
    end
  end
end  























task :auto_end_3_games => :environment do
puts "Updating games with 3 winner end statuses..."
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
  @num2 = @active_games.count
  @games_with_3_structure = []

  while @b < @num2 do    #get all games with winning structure 1 
    @game = Game.find(@active_games[@b])
    if  @game.winning_structure == 3 
     then
     @games_with_3_structure << @game.id
     @b += 1 
     else 
     @b += 1
    end
  end
  puts "Game(s) #{@games_with_3_structure} have winning struc 3"

  @c = 0 
  @num3 =  @games_with_3_structure.count
  @finished_games = []

  while @c < @num3       ##check which of the previous games have reached the end date 
   @game = Game.where(:id => @games_with_3_structure[@c]).first
   @end_date_integer = @game.game_end_date 
   @today_integer = Time.now.to_i - 21600
   @diff = @today_integer - @end_date_integer

   if @diff >= 0 
     then @finished_games << @game.id 
     @c += 1
     else 
     puts "game #{@game.id} with winning struct. 3 is not ready to end"
     @c += 1 
    end 
  end 
  puts "Game(s) #{@finished_games} have finished"

  unless @finished_games.empty?
    @d = 0 
    @num4 = @finished_games.count

    while @d < @num4 
      @game = Game.find(@finished_games[@d])
      #######1st_step add up total time at gym for all players #######
      @players = GameMember.where(:game_id => @game.id)
      number_of_players = @players.count  
   
      @e = 0
      @num5 = number_of_players

      while @e < @num5 do  ##assigns stats to users (adds up total minutes)
        @game_member = @players[@e]
        @game_member.active = 0
        checks = @game_member.successful_checks * 1000000
        total_minutes = @game_member.total_minutes_at_gym / 60 
        checks_and_minutes = checks + total_minutes
        @game_member.end_game_checks_evaluation = checks_and_minutes
        @game_member.save
        @e += 1
      end
      ###### end adding up total time at gym ###########

      ###### 2nd_step order the players by place now that minutes were factored in########
      @players = GameMember.where(:game_id => @game.id).order("end_game_checks_evaluation DESC")
   
      @f = 0
      @num6 = number_of_players

      while @f < @num6  do ####gives everyone a loss (changes the winner's losses later)
        @game_member = @players[@f]
        @stat = Stat.where(:winners_id => @game_member.user_id).first
        @stat.losses += 1
        @stat.save
        @f +=1
      end
      ###### end ordering by place #####################

      ###### begin stripe charges ######################
      @losers = 3
      @num7 = number_of_players

      while @losers < @num7  do  ###sends email notification to the losers 
        game_member = @players[@losers]
        user = User.find(game_member.user_id)
        place = @losers + 1 
        loser_checkins = game_member.successful_checks
        UserMailer.notify_loser(user, loser_checkins, place).deliver
        @losers +=1
      end


      ####### PAY THE WINNERS
      winner1 = User.find(@players[0].user_id)
      winner2 = User.find(@players[1].user_id)
      winner3 = User.find(@players[2].user_id)

      first = GameMember.where(:user_id => winner1.id, :game_id => @game).first
      first.final_standing = 1
      first.save
      first = Stat.where(:winners_id => winner1.id).first
      first.losses -= 1
      first.first_place_finishes += 1
      first.save

      second = GameMember.where(:user_id => winner2.id, :game_id => @game).first
      second.final_standing = 2
      second.save
      second = Stat.where(:winners_id => winner2.id).first
      second.losses -= 1
      second.second_place_finishes += 1
      second.save

      third = GameMember.where(:user_id => winner3.id, :game_id => @game).first
      third.final_standing = 3
      third.save
      third = Stat.where(:winners_id => winner3.id).first
      third.losses -= 1
      third.third_place_finishes += 1
      third.save
     
      unless @game.wager == 0 
        ####### define the payout amounts
        @first_place_percentage = 0.45
        @second_place_percentage = 0.27
        @third_place_percentage = 0.20
        @fitsby_percentage = 0.08

        winner1_money_won = (@game.stakes  * @first_place_percentage)
        winner2_money_won = (@game.stakes  * @second_place_percentage)
        winner3_money_won = (@game.stakes  *  @third_place_percentage)
        total_money_processed = (@game.stakes + (@game.players * 0.50))
        fitsby_money_won = (@game.stakes * @fitsby_percentage) + (0.50 * number_of_players)
        UserMailer.congratulate_winner1(winner1, winner1_money_won).deliver
        UserMailer.congratulate_winner2(winner2, winner2_money_won).deliver
        UserMailer.congratulate_winner3(winner3, winner3_money_won).deliver
        game_id = @game.id
        UserMailer.email_ourselves_to_pay_3_winners(game_id, winner1, winner1_money_won, winner2, winner2_money_won,
        winner3, winner3_money_won, fitsby_money_won, total_money_processed).deliver  
        puts "sent out mail and charges for money game #{@game_info.id}. Winning structure 3"
        else 
        winner1_money_won = 0 
        UserMailer.congratulate_winner1(winner1, winner1_money_won).deliver
        winner2_money_won = 0 
        UserMailer.congratulate_winner2(winner2, winner2_money_won).deliver
        winner3_money_won = 0 
        UserMailer.congratulate_winner3(winner3, winner3_money_won).deliver
        @total_amount_charged_to_losers = 0 
        fitsby_money_won = 0
        game_id = @game.id
        total_money_processed = 0
        UserMailer.email_ourselves_to_pay_3_winners(game_id, winner1, winner1_money_won, winner2, winner2_money_won,
        winner3, winner3_money_won, fitsby_money_won, total_money_processed).deliver 
        puts "sent out mail for free game #{@game_info.id}. Winning structure 3"
      end
      ####### END STRIPE ################################################
    
      ############# Start the PUSH notification ##########################################
      notification = Gcm::Notification.new
      notification.device = Gcm::Device.all.first
      notification.collapse_key = "Games"
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


task :make_games_private_1_day_after => :environment do 
  puts "Making games private..."
  @all_games = Game.where(:was_recently_initiated => 1).pluck(:id) #get all games 

  @a = 0 
  @num1 = @all_games.count 

  unless @all_games.empty?
    while @a < @num1 do        
      @game = Game.find(@all_games[@a])
      @game.is_private = "TRUE"
      @game.was_recently_initiated = 0 
      @game.save
      puts "made game #{@game.id} private"
      @a += 1
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
        unless ((user.enable_notifications == "FALSE") or (user.device_id == "0" ))

          notification = Gcm::Notification.new
          notification.device = Gcm::Device.all.first
          notification.collapse_key = "Games"
          notification.delay_while_idle = true
          @user = User.where(:id => @selected_game_member.user_id).first
          device = Gcm::Device.find(@user.device_id)
          @registration_id = device.registration_id   
          @game = Game.find(@game_ids[@a])
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
        @couner += 1 
      else 
        @counter += 1 
      end
    end
  end 











