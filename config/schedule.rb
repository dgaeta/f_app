every 1.day, :at => '6:52 pm' do
  runner "Game.auto_start_games"
end

every 1.day, :at => '12:01 am' do
  runner "Game.auto_end_games"
end