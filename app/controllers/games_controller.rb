class GamesController < ApplicationController
  
  
  # GET /games
  # GET /games.json
  def index
    @games = Game.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @games }
    end
  end

  # GET /games/1
  # GET /games/1.json
  def show
    @game = Game.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @game }
    end
  end

  # GET /games/new
  # GET /games/new.json
  def new
    @game = Game.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @game }
    end
  end

  # GET /games/1/edit
  def edit
    @game = Game.find(params[:id])
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(params[:game])
    @user_id = @game.creator_id

    @user = User.where(:id => @user_id).first
    @user_email = @user.email

     @gamemember = GameMember.create(:user_id => @user.id, :game_id => @game.id )
     @gamemember.save

     c = Comment.new(:from_user_id => @user.id, :first_name => @user.first_name, :last_name => @user.last_name, 
          :message => @user.first_name + "" + " just joined the game .", :from_game_id => @game.id)
     c.email = @user.email 
     c.save

        @game = Game.new(params[:game])
        @game.players = 1
        @first_name = @user.first_name.downcase
        @game.creator_id = @user.id
        @game.creator_first_name = @user.first_name
        @game.stakes = @game.wager
        @game.save

    
         if @user.save
        then 
       
        @game.players = 1
        @first_name = @user.first_name.downcase
        @game.creator_first_name = @user.first_name
        @game.stakes = @game.wager
        @game.save

        @gamemember = GameMember.create(:user_id => @user.id, :game_id => @game.id )
        @gamemember.save
        #@user = User.where(:id => @user.id)
        c = Comment.new(:from_user_id => @user.id, :first_name => @user.first_name, :last_name => @user.last_name, 
          :message => @user.first_name + "" + " just joined the game.", :from_game_id => @game.id)
        c.save

        variable = Time.now + 24*60*60 #1 day after time now at midnight
        variable = Time.at(variable).midnight
        variable = variable.to_i
        @game.game_start_date = variable

         
          @game = Game.where(:id => @game_ids[@a]).first #a 
         variable2 = ( Time.now + (@game.duration * (24*60*60))) #14 days after time now at mindnight
         variable2 = Time.at(variable2).midnight
         variable2 = variable2.to_i
         @game.game_end_date = variable2
         @game.save
      
            true_json =  { :status => "okay", :game_id => @game.id}
            render(json: JSON.pretty_generate(true_json) )
    
        else
         false_json = { :status => "fail."} 
        render(json: JSON.pretty_generate(false_json))
    end

  end





  # PUT /games/1
  # PUT /games/1.json
  def update
    @game = Game.find(params[:id])

    respond_to do |format|
      if @game.update_attributes(params[:game])
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game = Game.find(params[:id])
    @game.destroy

    respond_to do |format|
      format.html { redirect_to games_url }
      format.json { head :no_content }
    end
  end


 def create_game
    Stripe.api_key = @stripe_api_key   # this is our stripe test secret key (found on website)

    @user = User.where(:id => params[:user_id]).first
    @user_email = @user.email
    @wager = params[:wager]


    unless GameMember.where(:user_id=>params[:user_id], :game_id => params[:game_id]).first
      unless @wager == 0 
        # get the credit card details submitted by Android
        credit_card_number = params[:credit_card_number]
        credit_card_exp_month = params[:credit_card_exp_month]
        credit_card_exp_year = params[:credit_card_exp_year]
        credit_card_cvc = params[:credit_card_cvc]
    
        # create a Customer
        customer = Stripe::Customer.create(
        :card => [:number => credit_card_number, :exp_month => credit_card_exp_month, :exp_year => credit_card_exp_year, :cvc => credit_card_cvc],
        :email => @user.email ) 
        @user.update_attributes(:customer_id => customer.id)

            # Now, make a stripe column for database table 'users'
            # save the customer ID in your database so you can use it later
      end
      
      @stat = Stat.where(:winners_id => @user.id).first 
      @stat.games_played += 1 
      @stat.save
      @game = Game.new(params[:game])
      @game.creator_id = @user.id
      @game.players = 1
      @game.save
      @first_name = @user.first_name.downcase
      @game.creator_first_name = @user.first_name
      @game.stakes = @game.wager
      @game.is_private = params[:is_private]
      @game.goal_days = params[:goal_days]
      @game.save

      @gamemember = GameMember.create(:user_id => @user.id, :game_id => @game.id )
      @gamemember.save
      #@user = User.where(:id => @user.id)
      c = Comment.new(:from_user_id => @user.id, :first_name => @user.first_name, :last_name => @user.last_name, 
      :message => @user.first_name + "" + " created the game.", :from_game_id => @game.id)
      c.email = @user.email 
      c.save

      variable = (Time.now - 21600) + 24*60*60 #1 day after time now at midnight
      variable = Time.at(variable).midnight
      variable = variable.to_i
      @game.game_start_date = variable

      variable2 = ((Time.now - 21600)+ ( (@game.duration + 1) *24*60*60)) #14 days after time now at mindnight
      variable2 = Time.at(variable2).midnight
      variable2 = variable2.to_i
      @game.game_end_date = variable2
      @game.save
          
      true_json =  { :status => "okay", :game_id => @game.id}
      render(json: JSON.pretty_generate(true_json) )
    else 
      false_json = { :status => "fail."} 
      render(json: JSON.pretty_generate(false_json))
    end 
  end

  def public_games
    @public_games = Game.where(:is_private => "false", :game_active => 1)

    @user = User.find(params[:user_id])
    @all_of_users_games = GameMember.where(:user_id => @user.id).pluck(:game_id)
  

    unless @all_of_users_games[0] == nil  
          h = Hash.new(0)

             @a = 0 
             @num1 = @public_games.count
        
          while @a < @num1  do
            h[@public_games[@a].id] = 0
            @a +=1
           end

          @b = 0 
          @num2 = @all_of_users_games.count
        
          while @b < @num2  do
            h.delete(@all_of_users_games[@b]) 
            @b +=1
           end
   
          @games_to_display = h.keys

          @c = 0 
        @num3 = @games_to_display.count
        @public_games = []

         while @c < @num3  do
            @public_games << Game.where(:id => @games_to_display[@c]).first
            @c +=1
          end

       @public_games = @public_games.map do |game|
      {:id => game.id,
      :duration => game.duration,
      :wager => game.wager,
      :players => game.players,
      :stakes => game.stakes,
      :goal_days => game.goal_days, 
      :email => User.where(:id => game.creator_id).pluck(:email).first}
       end

        a_json =  { :status => "okay" , :public_games => @public_games }
        render(json: JSON.pretty_generate(a_json))


      else
         @public_games = Game.where("is_private = false")
         @public_games = @public_games.map do |game|
        {:id => game.id,
        :duration => game.duration,
        :wager => game.wager,
        :players => game.players,
        :stakes => game.stakes,
       :goal_days => game.goal_days, 
       :email => User.where(:id => game.creator_id).pluck(:email).first}
      end
        b_json =  { :status => "okay" , :public_games => @public_games }
        render(json: JSON.pretty_generate(b_json))
        
    end
  end

def winners_and_losers
    leaderboard_stats = GameMember.includes(:user).where(:game_id => params[:game_id]).order("successful_checks DESC")


       

      leaderboard_stats = leaderboard_stats.map do |member|
        {:user_id => member.user.id}
        #:first_name => member.first_name,
        #:successful_checks => member.successful_checks,
        #:first_place_finishes => member.first_place_finishes,
        #:second_place_finishes => member.second_place_finishes,
        #:third_place_finishes => member.third_place_finishes,
        #:losses => member.losses, 
        #:final_standing => member.final_standing}
     end
    #end leaderboard method

    first = leaderboard_stats[0]
    first = first[:user_id]
    first = GameMember.where(:user_id => first).first
    first.final_standing = 1
    first.save
    first = leaderboard_stats[0]
    first = first[:user_id]
    first = Stat.where(:winners_id => first).first
    first.losses -= 1
    first.first_place_finishes += 1
    first.save

    second = leaderboard_stats[1]
    second = second[:user_id]
    second = GameMember.where(:user_id => second).first
    second.final_standing = 2
    second.save
    second = leaderboard_stats[1]
    second = second[:user_id]
    second = Stat.where(:winners_id => second).first
    second.losses -= 1
    second.second_place_finishes += 1
    second.save

    third = leaderboard_stats[2]
    third = second[:user_id]
    third = GameMember.where(:user_id => third).first
    third.final_standing = 3
    third.save
    third = leaderboard_stats[2]
    third = third[:user_id]
    third = Stat.where(:winners_id => third).first
    third.losses -= 1
    third.third_place_finishes += 1
    third.save

     if public_games == nil 
      then 
        false_json = { :status => "fail."} 
        render(json: JSON.pretty_generate(false_json))
      else
        true_json =  { :status => "okay" , :leaderboard_stats => leaderboard_stats }
        render(json: JSON.pretty_generate(true_json))
    end

  end 


 
  def join_game
    Stripe.api_key = @stripe_api_key   # this is our stripe test secret key (found on website)
    
    user = User.where(:id => params[:user_id]).first
    user_email = user.email

    @game = Game.where(:id => params[:game_id]).first

    if user.save 
      then 
      unless GameMember.where(:user_id=>params[:user_id], :game_id => params[:game_id]).first
        unless @game.wager == 0 
        # get the credit card details submitted by Android
        credit_card_number = params[:credit_card_number]
        credit_card_exp_month = params[:credit_card_exp_month]
        credit_card_exp_year = params[:credit_card_exp_year]
        credit_card_cvc = params[:credit_card_cvc]
    
        # create a Customer
        customer = Stripe::Customer.create(
        :card => [:number => credit_card_number, :exp_month => credit_card_exp_month, :exp_year => credit_card_exp_year, :cvc => credit_card_cvc],
        :email => user_email ) 
        user.update_attributes(:customer_id => customer.id)

        # Now, make a stripe column for database table 'users'
        # save the customer ID in your database so you can use it later
      end

        game_member = GameMember.create(:user_id=>params[:user_id], :game_id => params[:game_id])
        game_member.save
        stat = Stat.where(:winners_id => user.id).first 
        stat.games_played += 1 
        stat.save
          
        wager = @game.wager
        current_stakes = @game.stakes
        new_stakes = wager + current_stakes
        total_players = @game.players
        total_players += 1
        @game.players = total_players
        @game.stakes = new_stakes
        @game.save
        stakes = @game.stakes

        user = User.find(game_member.user_id)
        c = Comment.new(:from_user_id => user.id, :first_name => user.first_name, :last_name => user.last_name, 
          :message => user.first_name + "" + " just joined the game!", :from_game_id => game_member.game_id)
        c.bold = "False"
        c.email = user.email 
        c.save


       

        true_json =  { :status => "okay", :game_id => @game.id, :creator_first_name => @game.creator_first_name }
        render(json: JSON.pretty_generate(true_json))
      else
        false_json = { :status => "fail."} 
        render(json: JSON.pretty_generate(false_json))
    end
   end
  end

  def countdown
    @game = Game.where(:id => params[:game_id]).first
    
    


     unless @game == nil
      then
        if @game.game_initialized == 0 
           game_start_date = @game.game_start_date
           days_remaining = (game_start_date - (Time.now.to_i - 21600))
           days_remaining = days_remaining / 24 
           days_remaining = days_remaining / 60 
           days_remaining = days_remaining / 60
           days_remaining = days_remaining + 1
           days_remaining = days_remaining.round
              @string = "Days left until game begins: #{days_remaining}"
       else 
           game_end_date = @game.game_end_date
           time_now = (Time.now - 21600)
           time_now = time_now.to_i
           days_remaining = (game_end_date - time_now)
           days_remaining = days_remaining / 24 
           days_remaining = days_remaining / 60 
           days_remaining = days_remaining / 60
           days_remaining = days_remaining + 1
           days_remaining = days_remaining.round
          if days_remaining < 0 
            then 
           @string = "Game Ended"
            else 
              @string = "Days left until game ends: #{days_remaining}"
          end
        end
      else 
        @string = "Get started by creating or join a game!"
      end
  
    if (@game == nil) or (days_remaining == nil)
      then 
        false_json = { :status => "fail."} 
        render(json: JSON.pretty_generate(false_json))
      else
        true_json =  { :status => "okay" , :string => @string }
        render(json: JSON.pretty_generate(true_json))
    end
  end

  def get_private_game_info
    @found_game = Game.find(params[:game_id])
    
    unless @found_game != nil
      @user_entered_creator_name = params[:first_name_of_creator]
      @user_entered_creator_name_downcased = @user_entered_creator_name.downcase
      @actual_game_creator_name = @found_game.creator_first_name
      @actual_game_creator_name_downcased = @actual_game_creator_name.downcase
      @user = User.find(params[:user_id])
      @game_member = GameMember.where(:game_id => params[:game_id], :user_id => @user.id).first
    
      ##### Compare actual game creator name and the name the user entered
      unless @game_member != nil
        @results = "Found Game"
        game_id = @found_game.id
        creator_first_name = @found_game.creator_first_name
        players = @found_game.players
        wager = @found_game.wager
        stakes = @found_game.stakes
        private_or_not = @found_game.is_private
        duration = @found_game.duration
        start_date = @found_game.game_start_date
        start_date = Time.at(start_date)
        start_date = start_date.strftime('%a %b %d')
        goal_days = @found_game.goal_days
        creator = User.find(@found_game.creator_id)
        creator_email = creator.email
        true_json =  { :status => "okay", :game_id => game_id, :creator_first_name => creator_first_name, :players => players, 
          :wager => wager, :stakes => stakes, :is_private => private_or_not, :duration => duration, :start_date => start_date, 
          :goal_days => goal_days, :email => creator_email}
        render(json: JSON.pretty_generate(true_json))
        puts "found game"
      else 
        @results = "You are already in this game"
        false_json = { :status => "fail.", :error => @error_string} 
        render(json: JSON.pretty_generate(false_json))
        puts "game member already exists"
      end
    else
      false_json = { :status => "fail.", :error => @error_string} 
      render(json: JSON.pretty_generate(false_json))
      puts "could not find that game"
    end
  end


  def single_game_info 
    @search_results = Game.where(:id => params[:game_id], :game_active => 1 ).first

    unless @search_results == nil 
      then
        game_id = @search_results.id
        creator_first_name = @search_results.creator_first_name
        players = @search_results.players
        wager = @search_results.wager
        stakes = @search_results.stakes
        private_or_not = @search_results.is_private
        duration = @search_results.duration
        start_date = @search_results.game_start_date
        start_date = Time.at(start_date)
        start_date = start_date.strftime("%-m/%-d/%-y")
        end_date = @search_results.game_end_date
        end_date = Time.at(end_date)
        end_date = end_date.strftime("%-m/%-d/%-y")
        winning_structure = @search_results.winning_structure
        creator_email = User.where(:id => @search_results.creator_id).first
        creator_email = creator_email.email
        goal_days = @search_results.goal_days
        true_json =  { :status => "okay", :game_id => game_id, :creator_first_name => creator_first_name, :players => players, 
        :wager => wager, :stakes => stakes, :is_private => private_or_not, :duration => duration, :start_date => start_date, 
        :end_date => end_date, :email => creator_email, :goal_days => goal_days}
        render(json: JSON.pretty_generate(true_json))
        else
        false_json = { :status => "fail."} 
        render(json: JSON.pretty_generate(false_json))
    end
  end


  def get_first_name 
    @game = Game.where(:id => params[:game_id]).pluck(:creator_first_name).first

    if @game == nil 
      then 
        false_json = { :status => "fail."} 
        render(json: JSON.pretty_generate(false_json))
      else
        true_json =  { :status => "okay" , :creator_first_name => @game}
        render(json: JSON.pretty_generate(true_json))
    end
  end

  def percentage_of_game 
     @game = Game.where(:id => params[:game_id]).first
     @goal_days = @game.goal_days
     @start_date = @game.game_start_date
     @end_date = @game.game_end_date
     @time_now = (Time.now - 21600)
     @diff = @time_now.to_i - @start_date

     if @diff >= 0 
      @today = @time_now.to_date.yday
      @end_day = Time.at(@end_date).to_date.yday
      @days_remaining = @end_day - @today
      if @days_remaining < 0 
        then @days_remaining = 365 - @today
          @days_remaining = @days_remaining + @end_day
        else 
           @days_remaining = @end_day - @today
      end
      @duration = @game.duration 
      @a = @duration - @days_remaining
      @percentage = @a.fdiv(@duration).round(2)
      true_json =  { :status => "okay" , :percentage => @percentage, :goal_days => @goal_days}
      render(json: JSON.pretty_generate(true_json))
    else 
      @percentage = 0 
      false_json = { :status => "fail.", :percentage => @percentage, :goal_days => @goal_days} 
      render(json: JSON.pretty_generate(false_json))
    end
  end

end
