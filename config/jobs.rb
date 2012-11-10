require File.expand_path("../environment", __FILE__)

job "game.check_status" do |params|

	game = Game.where(:id => params["id"]).first

	start = game.game_start_date
    start = start[0]
	time_now = Time.now.to_i
	diff = start - time_now	

	players = game.players
    players = players[0]
  
  if game.game_initialized == 0 
  	then 
  	   if  game.players >= 5 &&  diff <= 0
			game.game_initialized = 1
		  	game.save
	   elsif game.players >= 5 &&  diff > 0
	   	   game.game_initialized = 0
	   	   game.save
	   elsif game.players < 5 && diff <= 0
	   	   old_date_integer = game.game_start_date
	   	   new_date_integer = old_date_integer + 3*24*60*60
	   	   game_start_date = Time.at(new_date_integer)
	   	   game.game_start_date = 0
	   end
	else 
  	job.delete
  end
 end
