gem 'places'

require "stripe"
require_relative "../../app/controllers/application_controller"
require_relative "../../app/controllers/comments_controller"
require_relative "../../app/controllers/games_controller"

Stripe.api_key = "sk_0G8Utv86sXeIUY4EO6fif1hAypeDE"


desc "This task is called by the Heroku scheduler add-on"

task :auto_start_games => :environment do  
  all_Active_Games = Game.where(:game_active => 1, :game_initialized => 0)
  started_games = []

  unless all_Active_Games.length == 0
    all_Active_Games.each do |game|
      if game.players != 1 
        game.winning_structure = 1 if game.players < 3
        #Comment.gameStartComment(game.id)
        Game.gameHasStartedPush(game) #### updates user events here 
        GameMember.activatePlayers(game.id)
        game.game_start_date = (Time.now.to_i - 21600)
        game.game_end_date = (((Time.now.to_i) -21600) + (game.duration * (24*60*60)))
        game.game_initialized = 1 
        game.was_recently_initiated = 1
        started_games << game.id
        game.save
        Notifier.activated_games_notice(started_games).deliver
      else 
        Game.addDayToStartAndEnd(game.id)
        #Comment.gamePostponedComment(game.id)
      end
    end
  end
  puts "started games #{started_games}"

end


 

task :add_gyms_to_google => :environment do
      @client = Places::Client.new(:api_key => 'AIzaSyABFztuCfhqCsS_zLzmRv_q-dpDQ80K_gY')
      @unadded = Decidedlocation.where(:added_to_google => 0)
      
      unless @unadded.empty? 
       @number_of_unadded = @unadded.count

       @a = 0 
       @num = @number_of_unadded

       while @a < @num do
        @gym = @unadded[@a]
        @add = @client.add(:lat => @gym.geo_lat , :lng => @gym.geo_long, :accuracy => 100,
         :name => @gym.gym_name, :types => "gym")
        @gym.added_to_google = 1 
        @gym.save
        puts "added #{@gym.gym_name} to google api."
        @a += 1
       end 
    end
end  





task :auto_end_games => :environment do
  puts "Updating game end statuses..."

  all_init_and_active_Games = Game.where(:game_initialized => 1, :game_active => 1)
  finished_games = Game.findAndReturnFinishedGames(all_init_and_active_Games)

  unless finished_games.length == 0
    finished_games.each do |id|
      game = Game.where(:id => id).first
      playerIDs = GameMember.where(:game_id => game.id)
      numberOfWinners = Game.countWinnerIDs(playerIDs, game.goal_days) 
      Game.decideAndNotifyResults(playerIDs, numberOfWinners , game.goal_days)  ###updates user attributes
      Game.gameHasEndedPush(game.id)
      game.game_active = 0
      game.game_initialized = 0 
      game.is_private = "TRUE"
      game.save
    end
    Notifier.finished_games_notice(finished_games).deliver
  end
end





task :make_games_private_1_day_after => :environment do 
  puts "Making games private..."
  @init_and_active = Game.where(:game_initialized => 1, :game_active => 1) #get all games that were recently initialized

  unless @init_and_active.nil?
    @init_and_active.each do |game|
      game_start_integer = game.game_start_date
      now_integer = (Time.now.to_i - 21600)
      diff = now_integer - game_start_integer
      if diff >= 0 
        game.is_private = "TRUE"
        game.save
      end
    end
  end  
end



task :send_notification_to_inactive_game_members => :environment do 
  puts "Sending notifications to inactive members..."
  @all_game_members = GameMember.where(:active => "1", :successful_checks => "0")

  unless @all_game_members.empty?
    @a = 0 
    @num = @all_game_members.count 
    @time_now = Time.now.to_i - 21420

    while @a < @num do 
      @selected_game_member = GameMember.where(:id => @all_game_members[@a].id).first
      @last_activity = @selected_game_member.activated_at
 
      if ((@time_now - @last_activity) >= 172800) and ((@time_now - @last_activity)   <= 259200)
      then 
        puts "game member #{@selected_game_member.id} has been inactive for 2 days"
        @user = User.where(:id => @selected_game_member.user_id).first
        unless ((@user.enable_notifications == "FALSE") or (@user.device_id == "0" ))

          notification = Gcm::Notification.new
          notification.device = Gcm::Device.all.first
          notification.collapse_key = "no_check_in"
          notification.delay_while_idle = true
          @user = User.where(:id => @selected_game_member.user_id).first
          @device = Gcm::Device.where(:id => @user.device_id).first
          unless @device.nil?
            @registration_id = @device.registration_id  
            notification.data = {:registration_ids => [@registration_id],
            :data => {:message_text => "Hey! You haven\'t checked in yet."}}
            notification.save
          end
        end
        @a += 1 
       else 
         puts "game member #{@selected_game_member.id} has been inactive but not for 2 days"
        @a += 1
      end 
    end 
  end
end


task :fitsby_daily_report => :environment do
  puts "Sending fitsby report"

  dateNow = Time.now.to_date
  yesterday = (dateNow.day - 1)
  usersSignedUpYesterday = User.where(:signup_month => dateNow.month, :signup_day => yesterday, 
   :signup_year => dateNow.year)

  if usersSignedUpYesterday.empty?
    usersSignedUpYesterday = 0 
  else
    usersSignedUpYesterday =  usersSignedUpYesterday.length
  end
  Notifier.fitsby_daily_report(usersSignedUpYesterday, dateNow.month, yesterday, dateNow.year).deliver
end










