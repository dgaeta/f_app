class Game < ActiveRecord::Base
  
  belongs_to :user
  has_many :game_members, :dependent => :destroy
  #has_many :comments, :dependent => :destroy,  :through => :users
  attr_accessible :creator_id, :duration, :is_private, :wager, :players, :stakes, :game_start_date, :game_end_date, :creator_first_name, 
  :game_initialized, :winning_structure




  def self.auto_start_games 
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
                     puts "started game #{@game.id}"
                    comment = Comment.new(:from_game_id => @game.id,
                              :message => " The game has started!", :stamp => Time.now)
                    comment.save

                     player_ids = GameMember.where(:game_id => @game.id)
                     @u = 0 
                     @num6 = player_ids.count
                     while @u < @num6 do 
                     @game_member_id = player_ids[@u]
                     @user_email = User.where(:id => @game_member_id).pluck(:email)
                     @game_id = @game.id
                     UserMailer.notify_game_start(@game_member_id, @game_id).deliver
                     @u += 1 
                     end 

                elsif @game.players >= 4 and @diff > 0
                   @game.game_initialized = 0
                   puts "game #{@game.id} time hasnt passed to start, but has enough players"
                elsif @game.players < 4 and @diff <= 0 
                     @new_start_date = @start +  (24*60*60)
                     @new_end_date = @end + (1*24*60*60)
                     @game.game_start_date = @new_start_date 
                     @game.game_end_date = @new_end_date
                     @game.save 
                     @game_start_date = Date.new(@game.game_start_date)
                     @game_start_date = @game_start_date.strftime('%a %b %d')
                     puts "game #{@game.id} not enough players at start date, added 1 more days to start date"
                     comment = Comment.new(:from_game_id => @game.id,
                              :message => " The game start date has changed to #{@game_start_date}.", :stamp => Time.now)
                     comment.save
                     player_ids = GameMember.where(:game_id => @game.id)
                     @u = 0 
                     @num6 = player_ids.count
                     while @u < @num6 do 
                     @game_member_id = player_ids[@u]
                     @user_email = User.where(:id => @game_member_id).pluck(:email)
                     @game_id = @game.id
                     UserMailer.notify_new_game_start(@game_member_id, @game_id, @new_start_date ).deliver
                     @u += 1 
                   end

                elsif @game.players < 4 and @diff > 0
                  @game.game_initialized = 0
                  puts "game #{@game.id} does not have enough players and time hasnt passed"
                 end
            @i += 1 
          end
        end
    end


  def self.auto_end_games 
    @all_games = Game.where(:game_initialized => 1)
    @all_games_number = @all_games.count 
    @total_amount_charged_to_losers = 0 

    @i = 0 
    @num = @all_games_number

    while @i < @num do 
      @game = Game.where(:id => @all_games[@i]).first
      @start = @game.game_start_date
      @time_now = Time.now.to_i
      @diff = @start - @time_now
      @time_now = Time.now.to_i
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
    end

    def add_gyms_to_google
      @client = Places::Client.new(:api_key => 'AIzaSyABFztuCfhqCsS_zLzmRv_q-dpDQ80K_gY')
      @unadded = DecidedLocations.where(:added_to_google => 0)
      
      unless @unadded.empty? 
       @number_of_unadded = @unadded.count

       @a = 0 
       @num = @number_of_decisions

       while @a < @num do
        @unadded = @unadded[@a]
        @add = @client.add(:lat => @unadded.geo_lat, :lng => @unadded.geo_long, :accuracy => 50,
         :name => @unadded.gym_name, :types => "gym")
        @unadded.added_to_google = 1 
        @unadded.save
        @a += 1
       end 
      end
    end  


end
