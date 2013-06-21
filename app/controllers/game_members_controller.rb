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
    @commentable = @game_member
    @comments = @commentable.comments
    @comment = Comment.new

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
    number_of_players = GameMember.where(game_id => params[:game_id]).pluck(:game_id)
    
    if number_of_players == nil  
      false_json = { :status => "fail."} 
      render(json: JSON.pretty_generate(false_json))
    else
      true_json =  { :status => "okay" , :number_of_players => number_of_players }
      render(json: JSON.pretty_generate(true_json))
    end  
  end

 
 def check_in_request
    @user = User.find(params[:user_id])
    all_of_users_gameMembers = GameMember.where(:user_id => @user.id, :active => 1)
    geo_lat = params[:latitude]
    geo_long = params[:longitude]
    #@user.check_in_geo_lat = @geo_lat
    #@user.check_in_geo_long = @geo_long
 
    if (all_of_users_gameMembers.empty?)
      error_string = "Games have not Started"
      false_json = { :status => "fail.", :error => error_string} 
      render(json: JSON.pretty_generate(false_json))
      return
    end  
    last_checkin_time = all_of_users_gameMembers[0].checkins
    last_checkin_yday = Time.at(last_checkin_time).to_date.yday
    if (last_checkin_yday == Time.now.to_date.yday)
      error_string = "Only 1 check-in per day is allowed"
      false_json = { :status => "fail.", :error => error_string} 
      render(json: JSON.pretty_generate(false_json))
      return
    end 
    checked_in_for_games = []
    all_of_users_gameMembers.each do |player|
      player.checkins = (Time.now.to_i - 21420)
      player.save
      checked_in_for_games << player.game_id
    end
    true_json =  { :status => "okay", :checked_in_for_games_variable => checked_in_for_games}
    render(json: JSON.pretty_generate(true_json))
  end

  def check_out_request
    @user = User.find(params[:user_id])
    all_of_users_gameMembers = GameMember.where(:user_id => @user.id, :active => 1)
    #dist_in_miles = Geocoder::Calculations.distance_between([@user.check_in_geo_lat, @user.check_in_geo_long], geo_lat, geo_long)
    #dist_in_meters = dist_in_miles * 1609.34
    #gym_name = params[:gym_name]
   
    if (all_of_users_gameMembers.empty?)
      error_string = "Games have not Started"
      false_json = { :status => "fail.", :error => error_string} 
      render(json: JSON.pretty_generate(false_json))
      return
    end 
    timeNow = (Time.now.to_i - 21600)
    player = all_of_users_gameMembers[0]
    checkinTime = player.checkins
    diff = timeNow - checkinTime
    if (diff < 0)
      error_string = "Need 30 Min"
      false_json = { :status => "fail.", :error => error_string}
      render(json: JSON.pretty_generate(false_json))
      return
    end 
    
    all_of_users_gameMembers.each do |member|
      member.successful_checks += 1 
      member.save
      comment = Comment.new
      comment.from_game_id = member.game_id
      comment.from_user_id = @user.id
      comment.first_name = @user.first_name
      comment.last_name = @user.last_name
      comment.message = "#{@user.first_name} completed a #{30 + (diff/60)} minute workout"
      comment.save
    end   
    true_json =  { :status => "okay"}
    render(json: JSON.pretty_generate(true_json))   
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
      false_json = { :status => "fail."} 
      render(json: JSON.pretty_generate(false_json))
    else
      true_json =  { :status => "okay" , :leaderboard => leaderboard_stats, :goal_days => goal_days }
      render(json: JSON.pretty_generate(true_json))
    end
  end

  def stakes
    number_of_players = GameMember.where("game_id = ?", params[:game_id]).pluck(:game_id)
    wager = Game.where("id = ?", params[:game_id]).pluck(:wager)
    wager = wager[0].to_i


    stakes = (number_of_players.count * wager)
   
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

    new_total_players = GameMember.where(game_id => params[:game_id]).pluck(:game_id)
    new_total_players = new_total_players.count
    new_total_players += 1

    game = Game.where(:id => params[:game_id]).first
    game.stakes = new_stakes
    game.players = new_total_players
    game.save

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
    g = GameMember.where(:user_id => params[:user_id], :is_game_over => "FALSE").pluck(:game_id)

    unless g.nil?
      true_json =  { :status => "okay" , :games_user_is_in => g }
      render(json: JSON.pretty_generate(true_json)) 
    else
      false_json = { :status => "fail."} 
      render(json: JSON.pretty_generate(false_json))
    end
  end


  def push_position_change
    user_id = params[:user_id]
    game_ids = GameMember.where(:user_id => user_id, :active => "1").pluck(:game_id) 

    game_ids.each do |g_id|                #####cycle through this users games to see if position change occured 
      leaderboard_stats = GameMember.includes(:user).where(:game_id => g_id).order("successful_checks DESC").pluck("user_id")
      new_place = leaderboard_stats.index { |x| x == user_id }  
      @game_member = GameMember.where(:user_id => user_id, :game_id => g_id).first
      if @game_member.place == (new_place + 1)
        puts "no position change for Game member #{@game_member.id}"
      else 
        puts "position change for Game member #{@game_member.id}"
        @game_member.place = (new_place + 1)  
        @game_member.save 
        @user = User.where(:id => @game_member.user_id).first
        unless ((@user.device_registered == "FALSE") || (@user.enable_notifications == "FALSE"))
          registration_id = @user.gcm_registration_id
        end               
      end 
    end 
    true_json =  { :status => "okay"  }
    render(json: JSON.pretty_generate(true_json))
  end

end
