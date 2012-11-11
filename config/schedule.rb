every 1.day, :at => '2:03pm' do
  runner "Game.auto_start_games"
end

every 1.day, :at => '2:53 pm' do
  runner "Game.auto_end_games"
end