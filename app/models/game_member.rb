class GameMember < ActiveRecord::Base
  belongs_to :game 
  belongs_to :user
  attr_accessible :checkins, :checkouts, :game_id, :successful_checks, :user_id


  def self.activatePlayers(game_id)
  		game_members = GameMember.where(:game_id => game_id)
  		count = 0 

  		while count < game_members.length do
  			@player = game_members[count]
        @player.active = 1
  			@player.activated_at = (Time.now.to_i - 21600)
  			@player.save
  			count += 1  
  		end	
  	end

    def self.getGameMembers(user_id)
       players = GameMember.where(:user_id => @user.id, :is_game_over => "FALSE")

       players = players.map { |p|  :game_id => p.game_id, :user_id => p.user_id, :active => p.active}
       return players
    end

end
