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

    variable = (Time.now + 3*24*60*60) #3 days after time now
    variable = variable.to_i
    @game.game_start_date = variable

     variable2 = (Time.now + 17*24*60*60) #17 days after time now
     variable2 = variable2.to_i
     @game.game_end_date = variable2
    
  

    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render json: @game, status: :created, location: @game }
      else
        format.html { render action: "new" }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  def can_game_start_date
    start = Game.where( :id => params[:game_id]).pluck(:game_start_date)
    start = start[0]

    time_now = Time.now.to_i

    diff = start - time_now

    @true_string = "true"
    @false_string = "false"

    if diff <= 0 
      then render(:json => @true_string )
     else 
      render(:json => @false_string)
    end
  end

 def can_game_start_players
    players = Game.where(:id => params[:game_id]).pluck(:players)
    players = players[0]

    true_string = "true"
    false_string = "false"

    if players >= 5 
      then render(:json => true_string)
     else 
        render(:json => false_string)
    end
  end


  def can_game_end 
    end_date = Game.where( :id => params[:game_id]).pluck(:game_end_date)
    end_date = end_date[0]

    time_now = Time.now.to_i

    diff = time_now - end_date

    true_string = "true"
    false_string = "false"

    if diff >= 0 
      then render(:json => true_string )
     else 
      render(:json => false_string)
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
    Game.create(:creator_id => params[:user_id], :is_private => params[:is_private],
     :duration => params[:duration], :wager => params[:wager])


    variable = (Time.now + 3*24*60*60) #3 days after time now
    variable = variable.to_i
    @game.game_start_date = variable

     variable2 = (Time.now + 17*24*60*60) #17 days after time now
     variable2 = variable2.to_i
     @game.game_end_date = variable2
    
    message = "You created a game. Next steps => Get some rest. Listen to some tunes. Invite friends to your game."

    render(:json => message)
  end

  def public_games
    public_games = Game.where("is_private = false")

    public_games = public_games.map do |game|
      {:id => game.id,
      :duration => game.duration,
      :wager => game.wager,
      :players => game.players,
      :stakes => game.stakes}
    end

    render(:json => public_games)

  end

def winners_and_losers
    #this is leaderboard method from game_members controller 
    leaderboard_stats = GameMember.includes(:stat).
    where(:user_id => params[:winners_id]).
    order("successful_checks DESC")

       

      leaderboard_stats = leaderboard_stats.map do |member|
        {:user_id => member.id,
        :successful_checks => member.successful_checks,
        :first_place_finishes => member.stat.first_place_finishes,
        :second_place_finishes => member.stat.second_place_finishes,
        :third_place_finishes => member.stat.third_place_finishes,
        :losses => member.stat.losses}
     end
    #end leaderboard method

    
    leaderboard_stats[0].final_standing = 1
    leaderboard_stats[0].losses -= 1
    leaderboard[0].first_place_finishes += 1

    leaderboard_stats[1].final_standing = 2
    leaderboard_stats[1].losses -= 1
    leaderboard[1].second_place_finishes += 1

    leaderboard_stats[2].final_standing = 3
    leaderboard_stats[2].losses -= 1
    leaderboard[2].second_place_finishes += 1

  end 


  def join_game
    GameMember.create(:user_id=>params[:user_id], :game_id => params[:game_id])
    
    wager = Game.where(:id => params[:game_id]).pluck(:wager)
    wager = wager[0].to_i

    current_stakes = Game.where(:id => params[:game_id]).pluck(:stakes)
    current_stakes = current_stakes[0].to_i

    new_stakes = wager + current_stakes

    new_total_players = GameMember.where(:game_id => params[:game_id]).pluck(:game_id)
    new_total_players = new_total_players.count
    new_total_players += 1



    @game = Game.where(:id => params[:game_id]).first
    @game.update_attributes(:stakes => new_stakes)
    @game.update_attributes(:players  => new_total_players)
    #@game.save

    message = "You joined a game. Loading Motivation and Good Times..."


    render(:json => @game)
  end
    
end
