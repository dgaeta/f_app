# Load the rails application
require File.expand_path('../application', __FILE__)

ActiveSupport::Deprecation.silenced = true 

# Initialize the rails application
FApp::Application.initialize!


ActionMailer::Base.smtp_settings = {
  :user_name => "fitsby",
  :password => "illini12",
  :domain => "fitsby.com",
  :address => "smtp.sendgrid.net",
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}