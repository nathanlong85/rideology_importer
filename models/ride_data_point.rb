# frozen_string_literal: true

class RideDataPoint < ActiveRecord::Base
  belongs_to :ride
  before_save :filter_errors

  ERROR_STRING = 'Error'

  ERROR_FILTER_FIELDS = %w[
    engine_rpm
    gear_position
    gps_latitude
    gps_longitude
    water_temperature
    wheel_speed
  ].freeze


  private

  def filter_errors
    ERROR_FILTER_FIELDS.each do |field|
      __send__("#{field}=", nil) if __send__(field) == ERROR_STRING
    end
  end
end
