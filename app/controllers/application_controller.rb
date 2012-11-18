class ApplicationController < ActionController::Base
  protect_from_forgery :except => ["create"]
  before_filter :do_stripe



  def do_stripe
  	@stripe_api_key = "sk_0G8Utv86sXeIUY4EO6fif1hAypeDE" #also, change the Stripe key in the model game.rb's method self.auto_end_games"
  	# Test Secret Key: sk_0G8UQEXsgKNmNNdy7QRwKr7VIgjxl  
  	# Live Secret Key: sk_0G8Utv86sXeIUY4EO6fif1hAypeDE    	
  end

  def not_authenticated
  redirect_to login_url, :alert => "First login to access this page."
  end

  
end
