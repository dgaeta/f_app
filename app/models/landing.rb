class Landing < ActiveRecord::Base
  # attr_accessible :title, :body


  def fitsbyDailyStatus
  	dateNow = Time.now.to_date
  	usersSignedUpYesterday = User.where(:signup_month => dateNow.month, :signup_day => dateNow.day, 
  		:signup_year => dateNow.year)

  	unless usersSignedUpYesterday.empty?
  		fitsby_daily_status(usersSignedUpYesterday.length, dateNow.month, dateNow.day, dateNow.year).deliver!
  	end
  	
  end


end
