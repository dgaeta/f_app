class ApplicationController < ActionController::Base
  protect_from_forgery :except => ["create"]
  before_filter :do_stripe
  before_filter :payout_percentages

  def do_stripe
  	@stripe_api_key = "sk_0G8UQEXsgKNmNNdy7QRwKr7VIgjxl"
  end

  def payout_percentages
	@first_place_percentage = .50
    @second_place_percentage = .30
    @third_place_percentage = .05
    @fitsby_percentage = .15
  end
end
