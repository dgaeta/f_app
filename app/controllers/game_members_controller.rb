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
    @last_checkin = GameMember.where(:id => params[:game_member_id]).pluck(:checkins)
    @last_checkin = @last_checkin[0]

    if @last_checkin == 0 or @last_checkin == nil
      then
       @last_checkin = 0
      else
        @last_checkin = Time.at(@last_checkin)
        @last_checkin_cday = @last_checkin.to_date
        @last_checkin_cday = @last_checkin.mday
    end

    @calendar_day_now = Time.now.to_date
    @calendar_day_now = @calendar_day_now.mday

  
    if (@last_checkin == @calendar_day_now) or (@last_checkin_cday == @calendar_day_now)
      then 
       false_json = { :status => "fail."} 
       render(json: JSON.pretty_generate(false_json))
      else
      @game_member = GameMember.where(:id => params[:game_member_id]).first #find the current user and then bring him and his whole data down from the cloud
      @game_member.checkins = Time.now.to_i
      @game_member.save
      Comment.new(:game_member_id => params[:game_member_id] , :message => "Checked in at the GYM" , :stamp => Time.now)
      true_json =  { :status => "okay"}
      render(json: JSON.pretty_generate(true_json))
    end
  end

  def check_out_request
   @game_member = GameMember.find(params[:id])  #find the current user and then bring him and his whole data down from the cloud
   @game_member.checkouts = Time.now.to_i
   @game_member.save
   

   #VALIDATING TIME AT GYM 

    last_checkin = GameMember.where( "id = ?", params[:id]).pluck(:checkins)
    last_checkout = GameMember.where("id = ?", params[:id]).pluck(:checkouts)

    total_minutes_at_gym = last_checkout[0] - last_checkin[0]

    @game_member.total_minutes_at_gym += total_minutes_at_gym ##MAKE SURE THIS WORKS 

   
        if total_minutes_at_gym > 2700 
          @game_member.successful_checks += 1
          @game_member.save
           true_json =  { :status => "okay"}
           render(json: JSON.pretty_generate(true_json))
        else
          false_json = { :status => "fail."} 
          render(json: JSON.pretty_generate(false_json))
        end
  end


 

  def leaderboard 
    leaderboard_stats = GameMember.includes(:user). where(:game_id => params[:game_id]).order("successful_checks DESC")

       

      leaderboard_stats = leaderboard_stats.map do |member|
      {:user_id => member.user.id,
      :first_name => member.user.first_name,
      :last_name => member.user.last_name,
      :successful_checks => member.successful_checks}
    end


    render(:json => leaderboard_stats) #+ @leaderboard_last_name + @leaderboard_first_name)
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


    render(:json => game)
  end



end
