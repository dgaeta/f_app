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
    @game.stakes += @game.stakes
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
    number_of_games = @all_of_users_games.count
 
   #########################LOOP TO GET ACTIVE GAMES USER IS IN #######################################################################  
        @i = 0
        @num = number_of_games

          while @i < @num  do
             game_init_status = Game.where(:id => @all_of_users_games[@i]).pluck(:game_initialized).first
             if game_init_status == 0 
              then  @i +=1
            else
              @init_games = []
              @init_games << @all_of_users_games[@i]
              @i +=1
            end
          end
   ############################ END #################################################################################################### 

   ############IF STATEMENT TO SEE IF THEY HAVE ANY ACTIVE GAMES, THEN CHECK IF CHECKIN ALLOWED #######################################
     
      if @init_games[0] == nil #########GET OUT IF NO ACTIVE GAMES
         then 
            error = "no games active"
            false_json = { :status => "fail.", :error => error }
            render(json: JSON.pretty_generate(false_json)) 
      
         else ########## CHECKING IF CHECK INS ALLOWED#################################################################################
                  @game_member = GameMember.where(:user_id => @user.id, :game_id => @all_of_users_games[0]).first
                  @last_checkin = @game_member.checkins #GRAB FIRST GAME MEMBER AND GIVE ME THE LAST CHECKING INTEGER
                  if @last_checkin == 0 or @last_checkin == nil #IF NOTHING THERE THEN KEEP IT 0 
                     then
                      @last_checkin = 0
                      else   #IF THERE IS SOMETHING THERE THEN GIVE ME THE CALENDAR DAY OF THE LAST CHECKIN 
                      @last_checkin_time = Time.at(@last_checkin)
                      @last_checkin_date = @last_checkin_time.to_date
                      @last_checkin_mday = @last_checkin_date.mday
                  end
                  ############ DONE GETTING INFO ON LAST CALENDAR DAY AND TODAYS CDAY ########

                  @calendar_day_now = Time.now.to_date        #WHATS THE CALENDAR DAY TODAY?
                  @calendar_day_now = @calendar_day_now.mday
                ######################################################################################################################
                


                if @last_checkin_mday == @calendar_day_nowbdbdbd   #
                      then 
                       error = "not enough time between checkins"
                       false_json = { :status => "fail.", :error => error} 
                       render(json: JSON.pretty_generate(false_json))
                      else
              
                        @a = 0
                        @num2 = @init_games.count

                         while @a < @num2  do
                            @game_member = GameMember.where(:user_id => @user.id, :game_id => @init_games[@a]).first #find the current user and then bring him and his whole data down from the cloud
                            @game_member.checkins = Time.now.to_i
                            @game_member.save
                            @checked_in_for_games_variable = []
                            @checked_in_for_games_variable << @game_member.game.id
                            comment = Comment.new(:from_user_id => @game_member.user_id, :from_game_id => @game_member.game_id ,
                              :message => "Checked in at the GYM" , :stamp => Time.now)
                            comment.save
                            @a +=1
                          end
                        true_json =  { :status => "okay", :checked_in_for_games_variable => @checked_in_for_games_variable}
                        render(json: JSON.pretty_generate(true_json))
                end
                ######################################################################################################################
       end
  end

  def check_out_request
   @user = User.find(params[:user_id])
    @all_of_users_games = GameMember.where(:user_id => @user.id).pluck(:game_id)
    number_of_games = @all_of_users_games.count

         @i = 0
        @num = number_of_games

          while @i < @num  do
             game_init_status = Game.where(:id => @all_of_users_games[@i]).pluck(:game_initialized).first
             if game_init_status == 0 
              then  @i +=1
            else
              @init_games = []
              @init_games << @all_of_users_games[@i]
              @i +=1
            end
          end

          
          unless @init_games == nil 
            last_checkin = GameMember.where( :user_id => @user.id,:game_id => @init_games[0]).pluck(:checkins)
            current_checkout_request_time = Time.now.to_i
            total_minutes_at_gym = current_checkout_request_time - last_checkin[0]

            if total_minutes_at_gym > 0 #2700
              then

              @a = 0
              @num2 = @init_games

              while @a < @num2  do
                 game_member = Game.where( :user_id => params[:user_id], :game_id => @init_games[@a]).first
                 game_member.checkouts = Time.now.to_i
                 #game_member.total_minutes_at_gym += total_minutes_at_gym
                 game_member.successful_checks += 1
                 game_member.save
                 @a +=1
                 true_json =  { :status => "okay"}
                 render(json: JSON.pretty_generate(true_json))
              end
              else
                error_string = "not enough time"
                false_json = { :status => "fail.", :error => error_string} 
                render(json: JSON.pretty_generate(false_json))
             end
            else 
              error_string = "No active games"
              false_json = { :status => "fail.", :error => error_string} 
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

    if leaderboard_stats == nil 
      then 
        false_json = { :status => "fail."} 
        render(json: JSON.pretty_generate(false_json))
      else
        true_json =  { :status => "okay" , :leaderboard => leaderboard_stats }
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

    unless g[0] == nil
      then
      true_json =  { :status => "okay" , :games_user_is_in => g }
        render(json: JSON.pretty_generate(true_json)) 
      else
        false_json = { :status => "fail."} 
        render(json: JSON.pretty_generate(false_json))
      end
    end


end
