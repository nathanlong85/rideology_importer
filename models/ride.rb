# frozen_string_literal: true

class Ride < ActiveRecord::Base
  has_many :ride_data_points
end
