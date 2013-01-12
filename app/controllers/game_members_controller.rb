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
    number_of_games = @all_of_users_games.count
    @geo_lat = params[:latitude]
    @geo_long = params[:longitude]
    @user.check_in_geo_lat = @geo_lat
    @user.check_in_geo_long = @geo_long
    @user.save
 
   #########################LOOP TO GET ACTIVE GAMES USER IS IN #######################################################################  
        @i = 0
        @num = number_of_games
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
   ############################ END #################################################################################################### 

   ############IF STATEMENT TO SEE IF THEY HAVE ANY ACTIVE GAMES, THEN CHECK IF CHECKIN ALLOWED #######################################
     
      if @init_games[0] == nil #########GET OUT IF NO ACTIVE GAMES
         then 
            @error = "You can\'t check in right now because none of your games have started"
            false_json = { :status => "fail.", :error => @error }
            render(json: JSON.pretty_generate(false_json)) 
      
         else ########## CHECKING IF CHECK INS ALLOWED#################################################################################
                  @game_member = GameMember.where(:user_id => @user.id, :game_id => @init_games[0]).first
                  @last_checkout = @game_member.checkouts #GRAB FIRST GAME MEMBER AND GIVE ME THE LAST CHECKING INTEGER
                  if @last_checkout == 0 or @last_checkout == nil #IF NOTHING THERE THEN KEEP IT 0 
                     then
                      @last_checkout = 0
                      else   #IF THERE IS SOMETHING THERE THEN GIVE ME THE CALENDAR DAY OF THE LAST CHECKIN 
                      @last_checkout_time = Time.at(@last_checkout)
                      @last_checkout_date = @last_checkout_time.to_date
                      @last_checkout_mday = @last_checkout_date.mday
                  end
                  ############ DONE GETTING INFO ON LAST CALENDAR DAY AND TODAYS CDAY ########

                  @calendar_day_now = Time.now.to_date        #WHATS THE CALENDAR DAY TODAY?
                  @calendar_day_now = @calendar_day_now.mday
                ######################################################################################################################
                


                if @last_checkout_mday == @calendar_day_now   #
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
                            gym_name = params[:gym_name]
                            comment = Comment.new(:from_user_id => @game_member.user_id, :from_game_id => @init_games[@a] ,
                              :message => "#{@user.first_name} checked in at #{gym_name}.", :stamp => Time.now)
                            comment.first_name = @user.first_name
                            comment.last_name = @user.last_name
                            comment.email = @user.email 
                            comment.bold = "FALSE" 
                            comment.checkin = "TRUE"
                            comment.save
                          ####mailer
                            user_id = @user.id 
                            game_member_id = @game_member.id
                            check_in_time = @time
                            successful_checks_before = @game_member.successful_checks
                            geo_lat = @geo_lat
                            geo_long = @geo_long
                            UserMailer.testing_checkin_to_checkout(user_id, game_member_id, check_in_time, 
                            successful_checks_before, geo_lat, geo_long).deliver
                            #### end mailer 
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
   @geo_lat = params[:latitude]
   @geo_long = params[:longitude]
   @all_of_users_games = GameMember.where(:user_id => @user.id).pluck(:game_id)
   number_of_games = @all_of_users_games.count
   dist_in_miles = Geocoder::Calculations.distance_between([@user.check_in_geo_lat, @user.check_in_geo_long], 
    [@geo_lat,@geo_long])
   dist_in_meters = dist_in_miles * 1609.34

         @i = 0
        @num = number_of_games
        @init_games = []

          while @i < @num  do
             game = Game.where(:id => @all_of_users_games[@i], :game_active => "1").first
             unless game == nil 
              if (game.game_initialized == 1 ) & (game.game_active == 1)
              then
              @init_games << @all_of_users_games[@i]  
              @i +=1
              else         
              @i +=1
              end
            else 
             @i += 1
            end 
          end

          
          unless @init_games == nil 
          last_checkin = GameMember.where( :user_id => @user.id,:game_id => @init_games[0]).pluck(:checkins)
          @time_now = Time.now.to_i - 21420
          total_minutes_at_gym = @time_now - last_checkin[0] 
          @stat = Stat.where(:winners_id => @user.id).first
          @stat.total_minutes_at_gym += (total_minutes_at_gym / 60)
          @stat.save
         

           if ((total_minutes_at_gym > 1800) & (total_minutes_at_gym <  18000 )) & (dist_in_meters <= 50000)
           then
              @stat = Stat.where(:winners_id => @user.id).first
              @stat.successful_checks += 1
              @stat.save

              @a = 0
              @num2 = @init_games.count

              while @a < @num2  do
                 game_member = GameMember.where( :user_id => @user.id, :game_id => @init_games[@a]).first
                 last_checkin = game_member.checkins
                 @time_now = Time.now.to_i - 21420
                 @minutes = ((@time_now - last_checkin) / 60 )
                 game_member.checkouts = @minutes
                 game_member.total_minutes_at_gym += @minutes
                 game_member.successful_checks += 1
                 game_member.check_out_geo_lat = @geo_lat
                 game_member.check_out_geo_long = @geo_long
                 game_member.save
                 @a +=1
               end
                 true_json =  { :status => "okay"}
                 render(json: JSON.pretty_generate(true_json))
           
              elsif (total_minutes_at_gym < 1800) or (total_minutes_at_gym > 18000 )
                @a = 0 
                @num2 = @init_games.count
                while @a < @num2  do
                game_member = GameMember.where( :user_id => @user.id, :game_id => @init_games[@a]).first
                game_member.checkouts = 0
                game_member.save
                @a += 1 
                end
                puts "Time error"
                puts "#{total_minutes_at_gym}"
                error_string = "Time must be more than 30 minutes and less than 5 hours"
                false_json = { :status => "fail.", :error => error_string} 
                render(json: JSON.pretty_generate(false_json))

              elsif (dist_in_meters > 50000)
                @a = 0 
                @num2 = @init_games.count
                while @a < @num2  do
                game_member = GameMember.where( :user_id => @user.id, :game_id => @init_games[@a]).first
                game_member.checkouts = 0
                game_member.save
                @a += 1 
              end
               puts "coordinates error"
               puts "#{dist_in_meters}"
                error_string = "Location is not the same as check in - Log out to restart"
                false_json = { :status => "fail.", :error => error_string} 
                render(json: JSON.pretty_generate(false_json))
              else 
                error_string = "Error"
                false_json = { :status => "fail.", :error => error_string} 
                render(json: JSON.pretty_generate(false_json))
                
              end
            else 
              puts "no games error"
              error_string = "Sorry, you aren't in any games."
              false_json = { :status => "fail.", :error => error_string} 
              render(json: JSON.pretty_generate(false_json))
        end

  end


 

  def leaderboard 
    leaderboard_stats = GameMember.includes(:user).where(:game_id => params[:game_id]).order("successful_checks DESC")

       

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
  @game_ids = GameMember.where(:user_id => @user_id).pluck(:game_id)

   @i = 0
   @num = @game_ids.count
   @init_games = []

   while @i < @num  do
   game = Game.where(:id => @game_ids[@i], :game_active => 1).first
   unless game == nil 
     if (game.game_initialized == 1 ) & (game.game_active == 1)
     then
     @init_games << @game_ids[@i]  
     @i +=1
     else         
     @i +=1
     end
    else 
     @i += 1 
    end 
   end

   
  @a = 0 
  @num = @init_games.count
  while @a < @num do 
   leaderboard_stats = GameMember.includes(:user).where(:game_id => @init_games[@a]).order("successful_checks DESC")
   @user_ids =  GameMember.where(:game_id => @init_games[@a]).pluck(:user_id)
   leaderboard_stats = leaderboard_stats.map do |member|
     {:user_id => member.user.id, 
     :game_member_id => member.id}
    end

    @b = 0 
    @num2 = leaderboard_stats.count
    while @b < @num2 do 
     a =leaderboard_stats[@b]
     game_member = GameMember.find(a[:game_member_id])
     if game_member.place == (@b + 1)
       then 
       @b += 1
       else 
       game_member.place = (@b + 1)  
       game_member.save 
       user = User.find(game_member.user_id)
       if ((user.enable_notifications == "FALSE") or (user.device_id == "0" ))
        puts "skipped"
       else
       notification = Gcm::Notification.new
       notification.device = Gcm::Device.all.first
       notification.collapse_key = "Update"
       notification.delay_while_idle = true
       device = Gcm::Device.find(user.device_id)
       @registration_id = device.registration_id   
       @game = Game.find(@game_ids[@a])
       notification.data = {:registration_ids => [@registration_id],
       :data => {:message_text => "You are now in position: #{game_member.place}, in Fitsby game #{@game.id}!"}}
       notification.save
       end
       @b += 1
      end
    end
    @a += 1 
  end
   true_json =  { :status => "okay"  }
   render(json: JSON.pretty_generate(true_json)) 
end

end
