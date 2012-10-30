ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
   :address => "smtp.gmail.com", # or an external ip if your using a remote smtp
   :port => 587,
   :domain => "gmail.com",
   :authentication => :plain,
   :enable_starttls_auto => true,
   :user_name => "team@fitsby.com",
   :password => "illini12"  
 }