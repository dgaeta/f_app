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
    @game.players = 1
    @game.stakes = @game.wager
    @game.save

    GameMember.create(:user_id => @game.creator_id, :game_id => @game.id )

    variable = (Time.now + 3*24*60*60) #3 days after time now
    variable = variable.to_i
    @game.game_start_date = variable

     variable2 = (Time.now + 17*24*60*60) #17 days after time now
     variable2 = variable2.to_i
     @game.game_end_date = variable2
    
  
    respond_to do |format|
      if @game.save
        true_json =  { :status => "okay" }
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render json: JSON.pretty_generate(true_json) }
      else
        false_json = { :status => "fail.", :errors => @user.errors }
        format.html { render action: "new" }
        format.json {render json: JSON.pretty_generate(false_json) }
      end
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

    # get the credit card details submitted by Android
    credit_card_number = params[:credit_card_number]
    credit_card_exp_month = params[:credit_card_exp_month]
    credit_card_exp_year = params[:credit_card_exp_year]
    credit_card_cvc = params[:credit_card_cvc]
    
    # create a Customer
    customer = Stripe::Customer.create(
      :card => [:number => credit_card_number, :exp_month => credit_card_exp_month, :exp_year => credit_card_exp_year, :cvc => credit_card_cvc],
      :email => @user_email ) 
    @user.update_attributes(:customer_id => customer.id)

    # Now, make a stripe column for database table 'users'
    # save the customer ID in your database so you can use it later

    if @user.save
      then 
        @game = Game.new(params[:game])
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

         variable2 = (Time.now + 14*24*60*60) #14 days after time now at mindnight
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
      :stakes => game.stakes}
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
        :stakes => game.stakes}
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

    if user.save 
      then 
          unless GameMember.where(:user_id=>params[:user_id], :game_id => params[:game_id]).first 
          game_member = GameMember.create(:user_id=>params[:user_id], :game_id => params[:game_id])
          game_member.save

          game = Game.where(:id => params[:game_id]).first
          
          wager = game.wager
          
          current_stakes = game.stakes

          new_stakes = wager + current_stakes

          total_players = game.players
          total_players += 1
          game.players = total_players
          game.stakes = new_stakes
          game.save

        user = User.find(game_member.user_id)
        c = Comment.new(:from_user_id => user.id, :first_name => user.first_name, :last_name => user.last_name, 
          :message => user.first_name + "" + " just joined the game.", :from_game_id => game_member.game_id)
        c.save

              true_json =  { :status => "okay", :game_id => game.id, :creator_first_name => game.creator_first_name }
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
           days_remaining = (game_start_date - Time.now.to_i)
           days_remaining = days_remaining / 24 
           days_remaining = days_remaining / 60 
           days_remaining = days_remaining / 60
           days_remaining = days_remaining - 1
           days_remaining = days_remaining.round
              @string = "Days left until game begins: #{days_remaining}"
       else 
           game_end_date = @game.game_end_date
           Time_now = Time.now.to_i
           days_remaining = (game_end_date - Time_now)
           days_remaining = days_remaining / 24 
           days_remaining = days_remaining / 60 
           days_remaining = days_remaining / 60
           days_remaining = days_remaining - 1
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

    @search_results = Game.where(:id => params[:game_id], :creator_first_name.downcase => params[:first_name_of_creator].downcase, 
      :game_active => 1).first

    @user = User.find(params[:user_id])

    @game_member = GameMember.where(:game_id => params[:game_id], :user_id => @user.id).first

    unless (@game_member != nil) or (@search_results == nil) 
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
        start_date = start_date.strftime('%a %b %d')
        true_json =  { :status => "okay", :game_id => game_id, :creator_first_name => creator_first_name, :players => players, 
        :wager => wager, :stakes => stakes, :is_private => private_or_not, :duration => duration, :start_date => start_date}
        render(json: JSON.pretty_generate(true_json))
        else
        false_json = { :status => "fail."} 
        render(json: JSON.pretty_generate(false_json))
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
        true_json =  { :status => "okay", :game_id => game_id, :creator_first_name => creator_first_name, :players => players, 
        :wager => wager, :stakes => stakes, :is_private => private_or_not, :duration => duration, :start_date => start_date}
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

end
