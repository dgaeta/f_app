class Session < ActiveRecord::Base
   attr_accessible :user_id, :date_of_request, :deleted

 def self.deleteUser(user_id)
    @user = User.where(:id => user_id).first
    players = GameMember.where(:user_id => @user.id, :is_game_over => "FALSE")
    
    if players.empty?
      stat = Stat.where(:winners_id => @user.id).first
      stat.delete
      players =  GameMember.where(:user_id => @user_id)
      players.each { |p| p.delete }
      games = Game.where(:creator_id => @user.id)
      unless games.empty?
        games.each do |game| 
          game.creator_id = 101
          game.save 
        end
      end 
      gb = Gibbon.new
      gb.list_unsubscribe(:id => "3c9272b951", :email_address => user.email, :delete_member => true, 
      :send_goodbye => false, :send_notify => false)
      puts "User" + user.id + "deleted"
      user.delete
    end
  end

end
