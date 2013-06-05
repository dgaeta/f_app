class GameMembersController < ApplicationController



  # GET /game_members
  # GET /game_members.json
  def index
    @game_members = GameMember.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @game_members }
    end
  end

  # GET /game_members/1
  # GET /game_members/1.json
  def show
    @game_member = GameMember.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @game_member }
    end
  end

  # GET /game_members/new
  # GET /game_members/new.json
  def new
    @game_member = GameMember.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @game_member }
    end
  end

  # GET /game_members/1/edit
  def edit
    @game_member = GameMember.find(params[:id])
  end

  # POST /game_members
  # POST /game_members.json
  def create
    @game_member = GameMember.new(params[:game_member])
    @game_member.save

    @game = Game.where(:id => @game_member.game_id).first
    @game.players += 1
    @game.stakes += @game.wager
    @game.save

    respond_to do |format|
      if @game_member.save
        format.html { redirect_to @game_member, notice: 'Game member was successfully created.' }
        format.json { render json: @game_member, status: :created, location: @game_member }
      else
        format.html { render action: "new" }
        format.json { render json: @game_member.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /game_members/1
  # PUT /game_members/1.json
  def update
    @game_member = GameMember.find(params[:id])

    respond_to do |format|
      if @game_member.update_attributes(params[:game_member])
        format.html { redirect_to @game_member, notice: 'Game member was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @game_member.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /game_members/1
  # DELETE /game_members/1.json
  def destroy
    @game_member = GameMember.find(params[:id])
    @game_member.destroy

    respond_to do |format|
      format.html { redirect_to game_members_url }
      format.json { head :no_content }
    end
  end

  def number_of_players 
    number_of_players = GameMember.where("game_id = ?", params[:game_id]).pluck(:game_id)
    
    if number_of_players == nil 
      then 
        false_json = { :status => "fail."} 
        render(json: JSON.pretty_generate(false_json))
      else
        true_json =  { :status => "okay" , :number_of_players => number_of_players }
        render(json: JSON.pretty_generate(true_json))
    end

   
  end

 
 def check_in_request
    @user = User.find(params[:user_id])
    @all_of_users_games = GameMember.where(:user_id => @user.id).pluck(:game_id)
    @number_of_games = @all_of_users_games.count
    @geo_lat = params[:latitude]
    @geo_long = params[:longitude]
    @user.check_in_geo_lat = @geo_lat
    @user.check_in_geo_long = @geo_long
    @user.save
 
   ###LOOP TO GET ACTIVE GAMES USER IS IN  
    @i = 0
    @num = @number_of_games
    @init_games = []

    while @i < @num  do
      game = Game.where(:id => @all_of_users_games[@i]).first
      if (game.game_initialized == 1) & (game.game_active == 1)
        @init_games << @all_of_users_games[@i]
        @i +=1
      else
        @i +=1
      end
    end
   ## END LOOP 

   ###IF STATEMENT TO SEE IF THEY HAVE ANY ACTIVE GAMES, THEN CHECK IF CHECKIN ALLOWED 
     
    if @init_games[0] == nil #########GET OUT IF NO ACTIVE GAMES
      @error = "You can\'t check in right now because none of your games have started"
      false_json = { :status => "fail.", :error => @error }
      render(json: JSON.pretty_generate(false_json)) 
    else ########## CHECKING IF CHECK INS ALLOWED#################################################################################
      @game_member = GameMember.where(:user_id => @user.id, :game_id => @init_games[0]).first
      @last_checkout_mday = @game_member.last_checkout_date #GRAB FIRST GAME MEMBER AND GIVE ME THE LAST CHECKING INTEGER
    
      @calendar_day_now = (Time.now - 21400).mday       #WHATS THE CALENDAR DAY TODAY?
      
      if @last_checkout_mday == @calendar_day_now  
        then 
         @error = "Only 1 check-in per day is allowed"
         false_json = { :status => "fail.", :error => @error} 
         render(json: JSON.pretty_generate(false_json))
      else

        @a = 0
        @num2 = @init_games.count

       while @a < @num2  do
          @game_member = GameMember.where(:user_id => @user.id, :game_id => @init_games[@a]).first #find the current user and then bring him and his whole data down from the cloud
          @time =Time.now.to_i - 21420
          @game_member.checkins = @time
          @game_member.save 
          @checked_in_for_games_variable = []
          @checked_in_for_games_variable << @game_member.game.id
          @a += 1
        end
        true_json =  { :status => "okay", :checked_in_for_games_variable => @checked_in_for_games_variable}
        render(json: JSON.pretty_generate(true_json))
      end
      ######################################################################################################################
    end
  end

  def check_out_request
    @user = User.find(params[:user_id])
    all_of_users_gamesMembers = GameMember.where(:user_id => @user.id, :active => 1)
    dist_in_miles = Geocoder::Calculations.distance_between([@user.check_in_geo_lat, @user.check_in_geo_long], [geo_lat, geo_long])
    dist_in_meters = dist_in_miles * 1609.34
    gym_name = params[:gym_name]
    init_games = []
    false_json = { :status => "fail.", :error => error_string} 

    render(json: JSON.pretty_generate(false_json)); return; if (all_of_users_gamesMembers.empty?)
    timeNow = (Time.now.to_i - 21600)
    player = all_of_users_gamesMembers[0]
    checkinTime = player.checkins
    diff = timeNow - checkinTime
    render(json: JSON.pretty_generate(false_json)); return; if (diff < 0)
    
    all_of_users_gameMembers.each do |member|
      member.successful_checks += 1 
      member.save
    end      
  end

 

  def leaderboard 
    leaderboard_stats = GameMember.includes(:user).where(:game_id => params[:game_id]).order("successful_checks DESC")

      goal_days = Game.where(:id => params[:game_id]).pluck(:goal_days)
       

      leaderboard_stats = leaderboard_stats.map do |member|
      {:user_id => member.user.id,
      :first_name => member.user.first_name,
      :last_name => member.user.last_name,
      :successful_checks => member.successful_checks, 
      :email => member.user.email}
    end

    if leaderboard_stats == nil 
      then 
        false_json = { :status => "fail."} 
        render(json: JSON.pretty_generate(false_json))
      else
        true_json =  { :status => "okay" , :leaderboard => leaderboard_stats, :goal_days => goal_days }
        render(json: JSON.pretty_generate(true_json))
    end
   
  end

  def stakes
    number_of_players = GameMember.where("game_id = ?", params[:game_id]).pluck(:game_id)
    number_of_players = number_of_players.count
    wager = Game.where("id = ?", params[:game_id]).pluck(:wager)
    wager = wager[0].to_i

    stakes = number_of_players*wager

    
    if stakes == nil 
      then 
        false_json = { :status => "fail."} 
        render(json: JSON.pretty_generate(false_json))
      else
        true_json =  { :status => "okay" , :stakes => stakes }
        render(json: JSON.pretty_generate(true_json))
    end
  end

  def join_game
    GameMember.create(:user_id=>params[:user_id], :game_id => params[:game_id])
    
    wager = Game.where(:id => params[:game_id]).pluck(:wager)
    wager = wager[0].to_i

    current_stakes = Game.where(:id => params[:game_id]).pluck(:stakes)
    current_stakes = current_stakes[0].to_i

    new_stakes = wager + current_stakes

    new_total_players = GameMember.where("game_id = ?", params[:game_id]).pluck(:game_id)
    new_total_players = new_total_players.count
    new_total_players += 1



    game = Game.where(:id => params[:game_id])
    game.update_attributes(:stakes => new_stakes)
    game.update_attributes(:players => new_total_players)
    game.save

    message = "You joined a game. Loading Motivation and Good Times..."


    if game.save 
      then 
        true_json =  { :status => "okay" , :joined_game => game.id }
        render(json: JSON.pretty_generate(true_json))
      else
        false_json = { :status => "fail."} 
        render(json: JSON.pretty_generate(false_json))
    end
  end

  def games_user_is_in 
    g = GameMember.where(:user_id => params[:user_id]).pluck(:game_id)
    g_number = g.count 

    @a = 0 
    @num = g_number 
    @array = []

    while @a < @num do 
      b = Game.where(:id => g[@a], :game_active => "1").first
      unless b == nil 
      if b.game_active == 1
        then @array << b.id 
        @a += 1
      else 
        @a +=1
      end
    else 
      @a += 1 
    end
    end


    unless g.nil?
      then
      true_json =  { :status => "okay" , :games_user_is_in => @array }
        render(json: JSON.pretty_generate(true_json)) 
      else
        false_json = { :status => "fail."} 
        render(json: JSON.pretty_generate(false_json))
      end
    end

def push_position_change
  @user_id = params[:user_id]
  @game_ids = GameMember.where(:user_id => @user_id, :active => "1").pluck(:game_id)

  unless @game_ids.empty?
    @a = 0
    @num1 = @game_ids.count
    @init_games = []

    while @a < @num1  do  ###### get all initialized games 
      game = Game.where(:id => @game_ids[@a], :game_active => 1, :game_initialized => 1 ).first
      unless game == nil 
        @init_games << game.id
      end
      @a += 1 
    end

    @b = 0 
    @num2 = @init_games.count
  
    while @b < @num2 do #####cycle through this users games to see if position change occured 
      leaderboard_stats = GameMember.includes(:user).where(:game_id => @init_games[@b]).order("successful_checks DESC")
      #@user_ids =  GameMember.where(:game_id => @init_games[@b]).pluck(:user_id)
      leaderboard_stats = leaderboard_stats.map do |member|
        {:user_id => member.user.id, 
        :game_member_id => member.id}
      end

      @c = 0 
      @num3 = leaderboard_stats.count
    
      while @c < @num3 do ####compare previous place to new place 
        
        a =leaderboard_stats[@c]
        game_member = GameMember.find(a[:game_member_id])
        if game_member.place == (@c + 1)
          then 
          puts "no position change for Game member #{game_member.id}"
          @c += 1
        else 
          puts "position change for Game member #{game_member.id}"
          game_member.place = (@c + 1)  
          game_member.save 
          user = User.where(:id => game_member.user_id).first
          if ((user.enable_notifications == "FALSE") or (user.device_id == "0" ))
            puts "skipped game member #{game_member.id}"
          else
            device = Gcm::Device.find(user.device_id)
            @registration_id = device.registration_id  
            notification = Gcm::Notification.new
            notification.device = device
            notification.collapse_key = "games"
            notification.delay_while_idle = true   
            @game = Game.find(@game_ids[@a])
            notification.data = {:registration_ids => [@registration_id],
            :data => {:message_text => "You are now in position: #{game_member.place}, in Fitsby game #{@game.id}!"}}
            unless @registration_id.empty?
              notification.save
              puts "sent notif to game member #{game_member.id}"
            end
          end
          @c += 1
        end
      end
      @b += 1 
    end
  end  
  true_json =  { :status => "okay"  }
  render(json: JSON.pretty_generate(true_json))
end

  
end
