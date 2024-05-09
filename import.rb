#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pry'
require 'pry-byebug'

require 'active_record'
require 'csv'
require 'optparse'
require 'time'

require_relative './models/ride'
require_relative './models/ride_data_point'
require_relative './models/rideology_csv'

CSV_FIELDS_TO_SLICE = %w[
  elapsed_msec
  gear_position
  gps_latitude
  gps_longitude
].freeze

options = {
  file: nil
}

OptionParser.new do |opts|
  opts.banner = 'Usage: import.rb [options]'

  opts.on('-f', '--file FILE', 'File to import') do |f|
    options[:file] = f
  end

  opts.parse(ARGV)
end

unless options[:file]
  puts 'No input CSV file specified'
  exit 1
end

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  host: 'localhost',
  username: 'rideology',
  password: 'rideology',
  database: 'rideology'
)

started_at = Time.now

csv = RideologyCSV.new(options[:file])

ride = Ride.create!(
  title: csv.title,
  duration: csv.duration,
  finished_at: csv.finished_at
)

data_point_counter = 0
csv.csv_data.each do |row|
  data = row.to_h.slice(*CSV_FIELDS_TO_SLICE)

  data['ride_id'] = ride.id
  data['engine_rpm'] = row['engine_RPM'].to_i
  data['water_temperature'] = row['water_temperature'].to_f * 9 / 5 + 32
  data['wheel_speed'] = (row['wheel_speed'].to_i * 0.6213711922).round(1)

  RideDataPoint.create!(data)
  data_point_counter += 1
end

puts 'Created Ride:'
puts "\s\sID: #{ride.id}"
puts "\s\sTitle: #{ride.title}"
puts "\s\sImported #{data_point_counter} data points"
puts
puts "Total import time: #{Time.now - started_at} seconds"
