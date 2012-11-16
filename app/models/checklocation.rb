class Checklocation < ActiveRecord::Base
  attr_accessible :geo_lat, :geo_long, :gym_name, :requester_id
end
