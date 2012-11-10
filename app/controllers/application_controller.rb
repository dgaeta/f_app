class ApplicationController < ActionController::Base
  protect_from_forgery :except => ["create"]
  before_filter :do_stripe

  before_validation :downcase_email

private

def downcase_email
  self.email = self.email.downcase if self.email.present?
end


  def do_stripe
  	@stripe_api_key = "sk_0G8UQEXsgKNmNNdy7QRwKr7VIgjxl"
  end

  def not_authenticated
  redirect_to login_url, :alert => "First login to access this page."
  end

  
end
