class Game < ActiveRecord::Base
  
  belongs_to :user
  has_many :game_members, :dependent => :destroy
  #has_many :comments, :dependent => :destroy,  :through => :users
  attr_accessible :creator_id, :duration, :is_private, :wager, :players, :stakes, :game_start_date, :game_end_date, :creator_first_name, 
  :game_initialized




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

              if @game.players >= 5 and @diff <= 0 
                then @game.game_initialized = 1
                     @game.save   
                     puts "started game #{@game.id}"
                elsif @game.players >= 5 and @diff > 0
                   @game.game_initialized = 0
                   puts "game #{@game.id} time hasnt passed to start, but has enough players"
                elsif @game.players < 5 and @diff <= 0 
                     @new_start_date = @start +  (1*24*60*60)
                     @new_end_date = @end + (1*24*60*60)
                     @game.game_start_date = @new_start_date 
                     @game.game_end_date = @new_end_date
                     @game.save 
                     puts "game #{@game.id} not enough players at start date, added 3 more days to start date"
                elsif @game.players < 5 and @diff > 0
                  @game.game_initialized = 0
                  puts "game #{@game.id} does not have enough players and time hasnt passed"
                 end
            @i += 1 
          end
        end
    end


  def self.auto_end_games 
  	@stripe_api_key = "sk_0G8UQEXsgKNmNNdy7QRwKr7VIgjxl"
    @all_games = Game.where(:game_initialized => 1)
    @all_games_number = @all_games.count 

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
            Stripe.api_key = @stripe_api_key
            @players = GameMember.where(:game_id => @game.id).order("successful_checks DESC")
            number_of_players = @players.count  

            @i = 0
            @num = number_of_players 

            while @i < @num  do
            @player = @players[@i]
            @stat = Stat.where(:winners_id => @player.id).first
            @stat.losses += 1
            @save.save
            @i +=1
            end

            ################################# STRIPE BEGIN  #############################################################################
             #CHARGE THE LOSERS
             
             @losers = 3

             while @losers < @num  do
              user = @players[@losers]
              user = User.find(user.id)
              loser_checkins = GameMember.where(:user_id => user.id, :game_id => @game.id).pluck(:successful_checks).first
              loser_customer_id = user.customer_id   # if we saved user as a user's email, we need to call it now. Brent needs to send us all params of the losers
               game = Game.where(:id => @game.id).first
               amount_charged = (game.wager * 100) 
              
               Stripe::Charge.create(
                   :amount => amount_charged, # (example: 1000 is $10)
                   :currency => "usd",
                   :customer => loser_customer_id)

               UserMailer.notify_loser(user, amount_charged, loser_checkins).deliver
               
               @losers +=1
             end

             # PAY THE WINNERS
             winner1 = User.find(@players[0].id)
             winner2 = User.find(@players[1].id)
             winner3 = User.find(@players[2].id)

   
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


             # define the payout amounts
             @first_place_percentage = 0.50
             @second_place_percentage = 0.20
             @third_place_percentage = 0.15
             @fitsby_percentage = 0.15

             stakes = Game.where(:id => @game.id ).pluck(:stakes).first
             winner1_money_won = (stakes * @first_place_percentage)
             winner2_money_won = (stakes * @second_place_percentage)
             winner3_money_won = (stakes * @third_place_percentage)
             fitsby_money_won = (stakes * @fitsby_percentage)


             UserMailer.congratulate_winner1(winner1, winner1_money_won).deliver

             UserMailer.congratulate_winner2(winner2, winner2_money_won).deliver

             UserMailer.congratulate_winner3(winner3, winner3_money_won).deliver

             UserMailer.email_ourselves_to_pay_winners(winner1, winner1_money_won, winner2, winner2_money_won,
             winner3, winner3_money_won, fitsby_money_won ).deliver 

             puts "sent out mail and charges for game #{@game.id}"
             
             
         else 
           puts "the game #{@game.id} isnt ready to end"
        end
        @i += 1
      end 
    end
end
