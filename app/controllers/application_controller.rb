class ApplicationController < ActionController::Base
  protect_from_forgery :except => ["create"]
  before_filter :do_stripe


  def do_stripe
  	@stripe_api_key = "sk_0G8UQEXsgKNmNNdy7QRwKr7VIgjxl"
  end

  
end
