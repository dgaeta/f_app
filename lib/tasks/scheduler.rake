require 'rubygems'
  gem 'places'

desc "This task is called by the Heroku scheduler add-on"
task :auto_start_games => :environment do
  puts "Updating games start statuses..."
   @all_games = Game.where(:game_initialized => 0)
    @all_games_number = @all_games.count 

    @i = 0 
    @num = @all_games_number

       if @all_games[0] == nil
         then 
          json =  { :string => "all games active" }
          render(json: JSON.pretty_generate(json))
         else 
	        while @i < @num do 
		      @game = Game.where(:id => @all_games[@i]).first
		      @start = @game.game_start_date
		      @end = @game.game_end_date

              @time_now = Time.now.to_i

              @diff = @start - @time_now

	            if @game.players >= 4 and @diff <= 0 
	             then @game.game_initialized = 1
	                @game.is_private = "TRUE" 
	                @game.save   
                  @comment = Comment.new(:from_game_id => @game.id , :from_user_id => 101,  :email => "team@fitsby.com", :bold => "TRUE",  
                  :first_name => "ANNOUNCEMENT",  :last_name => " " , :message => "The game has started!", :stamp => Time.now)
                  @comment.email = "team@fitsby.com"
                  @comment.from_user_id = 101
                  @comment.bold = "TRUE"
                  @comment.save
	                puts "started game #{@game.id}"
	             elsif @game.players >= 4 and @diff > 0
	                @game.game_initialized = 0
	                puts "game #{@game.id} time hasnt passed to start, but has enough players"
	             elsif @game.players < 4 and @diff <= 0 
	                @new_start_date = @start +  (24*60*60)
	                @new_end_date = @end + (1*24*60*60)
	                @game.game_start_date = @new_start_date 
	                @game.game_end_date = @new_end_date
	                @game.save 
                  @comment = Comment.new(:from_game_id => @game.id, :email => "team@fitsby.com", :from_user_id => 101, :first_name => "ANNOUNCEMENT", 
                    :last_name => " " , :bold => "TRUE", :message => "The game start date has been pushed forward 1 day!", :stamp => Time.now)
                  @comment.email = "team@fitsby.com"
                  @comment.from_user_id = 101
                  @comment.bold = "TRUE"
                  @comment.save
                  puts "game #{@game.id} not enough players at start date, added 1 more days to start date"
	             elsif @game.players < 4 and @diff > 0
	             @game.game_initialized = 0
	             puts "game #{@game.id} does not have enough players and time hasnt passed"
	            end
	         @i += 1 
	       end
        end
  puts "done."
end

task :auto_end_games => :environment do
  puts "Updating games end statuses..."
    @all_games = Game.where(:game_initialized => 1)
    @all_games_number = @all_games.count 
    @total_amount_charged_to_losers = 0 

    @i = 0 
    @num = @all_games_number

    while @i < @num do 
      @game = Game.where(:id => @all_games[@i]).first
      @start = @game.game_start_date
      @time_now = Time.now - 21600
      @time_now = @time_now.to_i
      @diff = @time_now - @game.game_end_date  
      if @diff >= 0
        then 
         @players = GameMember.where(:game_id => @game.id)
         number_of_players = @players.count  
         @e = 0
         @num4 = number_of_players
         while @e < @num4 do
           @game_member = @players[@e]
           checks = @game_member.successful_checks * 1000000
           total_minutes = @game_member.total_minutes_at_gym / 60 
           checks_and_minutes = checks + total_minutes
           @game_member.end_game_checks_evaluation = checks_and_minutes
           @game_member.save
           @e += 1
          end
         @players = GameMember.where(:game_id => @game.id).order("end_game_checks_evaluation DESC")
         @i = 0
         @num = number_of_players 
         while @i < @num  do
           @player = @players[@i]
           @stat = Stat.where(:winners_id => @players[@i]).first
           @stat = @stat
           @stat.losses += 1
           @stat.save
           @i +=1
          end

            ################################# STRIPE BEGIN  #############################################################################
             #CHARGE THE LOSER
        if @game.winning_structure == 3 
         then 
           @losers = 3
           while @losers < @num  do
             user = @players[@losers]
             user = User.find(user)
             loser_checkins = GameMember.where(:user_id => user.id, :game_id => @game.id).pluck(:successful_checks).first
             @game = Game.where(:id => @game.id).first
             place = @losers + 1 
             UserMailer.notify_loser(user, loser_checkins, place).deliver
             @losers +=1
            end

            # PAY THE WINNERS
            winner1 = User.find(@players[0])
            winner2 = User.find(@players[1])
            winner3 = User.find(@players[2])

   
            first = GameMember.where(:user_id => winner1.id, :game_id => @game.id).first
            first.final_standing = 1
            first.save
            first = Stat.where(:winners_id => winner1).first
            first.losses -= 1
            first.first_place_finishes += 1
            first.save

            second = GameMember.where(:user_id => winner2.id, :game_id => @game.id).first
            second.final_standing = 2
            second.save
            second = Stat.where(:winners_id => winner2.id).first
            second.losses -= 1
            second.second_place_finishes += 1
            second.save

            third = GameMember.where(:user_id => winner3.id, :game_id => @game.id).first
            third.final_standing = 3
            third.save
            third = Stat.where(:winners_id => winner3.id).first
            third.losses -= 1
            third.third_place_finishes += 1
            third.save

            unless @game.wager == 0 
             # define the payout amounts
             @first_place_percentage = 0.45
             @second_place_percentage = 0.25
             @third_place_percentage = 0.15
             @fitsby_percentage = 0.15

             stakes = Game.where(:id => @game.id ).pluck(:stakes).first
             winner1_money_won = (stakes  * @first_place_percentage)
             winner2_money_won = (stakes  * @second_place_percentage)
             winner3_money_won = (stakes  *  @third_place_percentage)
             fitsby_money_won = (stakes  * @fitsby_percentage) + (0.50 * @number_of_players)


             UserMailer.congratulate_winner1(winner1, winner1_money_won).deliver

             UserMailer.congratulate_winner2(winner2, winner2_money_won).deliver

             UserMailer.congratulate_winner3(winner3, winner3_money_won).deliver

             UserMailer.email_ourselves_to_pay_winners(@game_id, winner1, winner1_money_won, winner2, winner2_money_won,
             winner3, winner3_money_won, fitsby_money_won, @total_amount_charged_to_losers ).deliver 
           else 
             winner1_money_won = 0 
             UserMailer.congratulate_winner1(winner1, winner1_money_won).deliver
             winner2_money_won = 0 
             UserMailer.congratulate_winner2(winner2, winner2_money_won).deliver
             winner3_money_won = 0 
             UserMailer.congratulate_winner3(winner3, winner3_money_won).deliver
             @total_amount_charged_to_losers = 0 
             fitsby_money_won = 0
             UserMailer.email_ourselves_to_pay_1_winner(@game_id, winner1, winner1_money_won, fitsby_money_won, @total_amount_charged_to_losers ).deliver 
             puts "sent out mail and charges for game #{@game.id}"
           end
         else ########################case if winning structure is winner take all #####################################################
           @losers = 1

            while @losers < @num  do
             user = @players[@losers]
             user = User.find(user)
             place = @losers + 1 
             loser_checkins = GameMember.where(:user_id => user.id, :game_id => @game.id).pluck(:successful_checks).first
             @game = Game.where(:id => @game.id).first
             UserMailer.notify_loser(user, loser_checkins, place).deliver
             @losers +=1
            end

           # PAY THE WINNERS
           winner1 = User.find(@players[0])
          
           first = GameMember.where(:user_id => winner1.id, :game_id => @game.id).first
           first.final_standing = 1
           first.save
           first = Stat.where(:winners_id => winner1).first
           first.losses -= 1
           first.first_place_finishes += 1
           first.save

           unless @game.wager == 0 
             # define the payout amounts
             @first_place_percentage = 0.85
             @fitsby_percentage = 0.15

             stakes = Game.where(:id => @game.id ).pluck(:stakes).first
             winner1_money_won = (stakes  * @first_place_percentage)
             fitsby_money_won = (stakes * @fitsby_percentage) + (0.50 * @number_of_players)
             UserMailer.congratulate_winner1(winner1, winner1_money_won).deliver
             UserMailer.email_ourselves_to_pay_1_winner(@game_id, winner1, winner1_money_won, fitsby_money_won, @total_amount_charged_to_losers ).deliver 
           else 
             winner1_money_won = 0 
             UserMailer.congratulate_winner1(winner1, winner1_money_won).deliver
             @total_amount_charged_to_losers = 0 
             fitsby_money_won = 0
             UserMailer.email_ourselves_to_pay_1_winner(@game_id, winner1, winner1_money_won, fitsby_money_won, @total_amount_charged_to_losers ).deliver 
           end
           @game.game_active = 0
           @game.save
           puts "sent out mail and charges for game #{@game.id}"
          end
         else 
          puts "the game #{@game.id} isnt ready to end"
        end
        @i += 1
      end 
      puts "done"
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
  @all_games = Game.where(:game_initialized => 1).pluck(:id)

  @z = 0 
  @numz = @all_games.count 
  @active_games = []

  while @z < @numz do 
    @game = Game.find(@all_games[@z])
    if @game.game_active == 1 
    then 
     @active_games << @all_games[@z]
     @z += 1 
    else 
     @z += 1 
    end
  end 

  @a = 0 
  @num = @active_games.count
  @games_with_1_structure = []

  while @a < @num do 
   @game = Game.find(@active_games[@a])
    if  @game.winning_structure == 1 
    then
     @games_with_1_structure << @game.id
     @a += 1 
    else 
     @a += 1
    end
  end

  @b = 0 
  @num2 =  @games_with_1_structure.count
  @finished_games = []

  while @b < @num2 
   @game = Game.where(:id => @games_with_1_structure[@b]).first
   @end_date_integer = @game.game_end_date 
   @today_integer = Time.now.to_i - 21600
   @diff = @today_integer - @end_date_integer
      
   if @diff >= 0 
   then
     #######1st_step add up total time at gym for all players #######
     @players = GameMember.where(:game_id => @game.id)
     number_of_players = @players.count  
   
     @c = 0 
     @num3 = number_of_players
     while @c < @num3 do
       @game_member = @players[@c]
       checks = @game_member.successful_checks * 1000000
       total_minutes = @game_member.total_minutes_at_gym / 60 
       checks_and_minutes = checks + total_minutes
       @game_member.end_game_checks_evaluation = checks_and_minutes
       @game_member.save
       @c += 1
      end
     ###### end adding up total time at gym ###########

     ###### 2nd_step order the players by place########
     @players = GameMember.where(:game_id => @game.id).order("end_game_checks_evaluation DESC")
   
     @i = 0
     @num = number_of_players 
     while @i < @num  do
       @game_member = @players[@i]
       @stat = Stat.where(:winners_id => @game_member.user_id).first
       @stat.losses += 1
       @stat.save
       @i +=1
      end
     ###### end ordering by place #####################

     ###### begin stripe charges ######################
     @losers = 1

     while @losers < @num  do
       game_member = @players[@losers]
       user = User.find(game_member.user_id)
       place = @losers + 1 
       loser_checkins = game_member.successful_checks
       @game = Game.where(:id => @game.id).first
       UserMailer.notify_loser(user, loser_checkins, place).deliver
       @losers +=1
      end

     ####### PAY THE WINNERS
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
       @first_place_percentage = 0.85
       @fitsby_percentage = 0.15

       winner1_money_won = (@game.stakes  * @first_place_percentage)
       fitsby_money_won = (@game.stakes * @fitsby_percentage) + (0.50 * @number_of_players)
       UserMailer.congratulate_winner1(winner1, winner1_money_won).deliver
       UserMailer.email_ourselves_to_pay_1_winner(@game_id, winner1, winner1_money_won, fitsby_money_won).deliver 
      else 
       winner1_money_won = 0 
       UserMailer.congratulate_winner1(winner1, winner1_money_won).deliver
       @total_amount_charged_to_losers = 0 
       fitsby_money_won = 0
       UserMailer.email_ourselves_to_pay_1_winner(@game_id, winner1, winner1_money_won, fitsby_money_won).deliver 
      end
    
     ###### inactivate the game, put status, move to next game #########
     @game.game_active = 0
     @game.save
     puts "sent out mail and charges for game #{@game.id}"
     @b += 1
   else 
     puts "game #{@game.id} with winning struct. 1 is not ready to end"
     @b += 1
   end
 end
end 


task :auto_end_3_games => :environment do
puts "Updating games with 3 winner end statuses..."
 @all_games = Game.where(:game_active => 1).pluck(:id)
  @all_games_number = @all_games.count 

   
  @a = 0 
  @num = @all_games_number
  @games_with_3_structure = []

  while @a < @num do 
   @game = Game.where(:id => @all_games[@a]).first
    if  @game.winning_structure == 3 
    then
     @games_with_3_structure << @game.id
     @a += 1 
    else 
     @a += 1
    end
  end

  @b = 0 
  @num2 =  @games_with_3_structure.count
  @finished_games = []

  while @b < @num2 
   @game = Game.where(:id => @games_with_3_structure[@b]).first
   @end_date_integer = @game.game_end_date 
   @today_integer = Time.now.to_i - 21600
   @diff = @today_integer - @end_date_integer
      
   if @diff >= 0 
   then
     #######1st_step add up total time at gym for all players #######
     @players = GameMember.where(:game_id => @game.id)
     number_of_players = @players.count  
   
     @c = 0
     @num3 = number_of_players
     while @c < @num3 do
       @game_member = @players[@c]
       checks = @game_member.successful_checks * 1000000
       total_minutes = @game_member.total_minutes_at_gym / 60 
       checks_and_minutes = checks + total_minutes
       @game_member.end_game_checks_evaluation = checks_and_minutes
       @game_member.save
       @c += 1
      end
     ###### end adding up total time at gym ###########

     ###### 2nd_step order the players by place########
     @players = GameMember.where(:game_id => @game.id).order("end_game_checks_evaluation DESC")
   
     @i = 0
     @num = number_of_players 
     while @i < @num  do
       @game_member = @players[@i]
       @stat = Stat.where(:winners_id => @game_member.user_id).first
       @stat.losses += 1
       @stat.save
       @i +=1
      end
     ###### end ordering by place #####################

     ###### begin stripe charges ######################
     @losers = 3
     @num = number_of_players


     while @losers < @num  do
       game_member = @players[@losers]
       user = User.find(game_member.user_id)
       place = @losers + 1 
       loser_checkins = game_member.successful_checks
       @game = game_member.game_id
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
     
     @game_info = Game.where(:id => @game).first
     unless @game_info.wager == 0 
       ####### define the payout amounts
       @first_place_percentage = 0.45
       @second_place_percentage = 0.25
       @third_place_percentage = 0.15
       @fitsby_percentage = 0.15

       winner1_money_won = (@game_info.stakes  * @first_place_percentage)
       winner2_money_won = (@game_info.stakes  * @second_place_percentage)
       winner3_money_won = (@game_info.stakes  *  @third_place_percentage)
       fitsby_money_won = (@game_info.stakes * @fitsby_percentage) + (0.50 * @number_of_players)
       UserMailer.congratulate_winner1(winner1, winner1_money_won).deliver
       UserMailer.congratulate_winner2(winner2, winner2_money_won).deliver
       UserMailer.congratulate_winner3(winner3, winner3_money_won).deliver
       UserMailer.email_ourselves_to_pay_1_winner(@game_info.id, winner1, winner1_money_won, winner2, winner2_money_won,
       winner3, winner3_money_won, fitsby_money_won).deliver  
       puts "sent out mail and charges for money game #{@game.id}. Winning structure 3"
      else 
       winner1_money_won = 0 
       UserMailer.congratulate_winner1(winner1, winner1_money_won).deliver
       winner2_money_won = 0 
       UserMailer.congratulate_winner2(winner2, winner2_money_won).deliver
       winner3_money_won = 0 
       UserMailer.congratulate_winner3(winner3, winner3_money_won).deliver
       @total_amount_charged_to_losers = 0 
       fitsby_money_won = 0
       UserMailer.email_ourselves_to_pay_3_winner(@game_id, winner1, winner1_money_won, fitsby_money_won).deliver 
       puts "sent out mail for free game #{@game.id}. Winning structure 3"
      end
     ####### END STRIPE ################################################
    
     ###### inactivate the game, put status, move to next game #########
     @game.game_active = 0
     @game.save
     @b += 1
   else 
     puts "game #{@game.id} with winning struct. 3 is not ready to end"
     @b += 1
   end
 end
end 












