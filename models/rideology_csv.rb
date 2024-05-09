# frozen_string_literal: true

class RideologyCSV
  METADATA_ROW_MAPPING = {
    title: 1,
    duration: 5
  }.freeze

  METADATA_VALUE_IDX = 2

  attr_reader :csv_data, :csv_file, :duration,:finished_at, :metadata, :title

  def initialize(csv_file)
    self.csv_file = csv_file
    parse_csv_file
  end

  private

  attr_writer :csv_data, :csv_file, :duration,:finished_at, :metadata, :title

  def read_and_split_csv
    file = File.open(csv_file)

    self.metadata = file.first(7).join
    self.csv_data = CSV.parse(file.read, headers: true)

    file.close
  end

  # The title contains the end date and time of the ride
  def extract_finished_at
    datetime_regex = %r{(\d{4}/\d{2}/\d{2} \d{2}:\d{2} (?:AM|PM))}
    datetime_match = title&.match(datetime_regex)
    return nil unless datetime_match

    DateTime.parse(datetime_match[1]).strftime('%FT%T')
  end

  def parse_metadata
    parsed = CSV.parse(metadata, headers: false)

    self.title =
      parsed[METADATA_ROW_MAPPING[:title]][METADATA_VALUE_IDX]

    self.duration =
      parsed[METADATA_ROW_MAPPING[:duration]][METADATA_VALUE_IDX].to_i

    self.finished_at = extract_finished_at
  end

  def parse_csv_file
    read_and_split_csv
    parse_metadata
  end
end
