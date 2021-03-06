class LiveRowNormalizer
  def self.normalize(csv_row)
    new(csv_row).normalize
  end

  def initialize(csv_row)
    @row = csv_row.to_hash.underscore_keys
  end

  def normalize
    strip_white_space
    normalize_times
    normalize_booleans
    row
  end

  private

  attr_reader :row

  TIME_PARAMS = [:time_in, :time_out]
  BOOLEAN_PARAMS = [:pacer_in, :pacer_out, :dropped_here]
  AFFIRMATIVE_LETTERS = %w(t y)

  def strip_white_space
    row.transform_values! { |v| v&.strip.presence || v.presence }
  end

  def normalize_times
    TIME_PARAMS.each { |time_param| row[time_param] = TimeConversion.file_to_military(row[time_param]) }
  end

  def normalize_booleans
    BOOLEAN_PARAMS.each { |boolean_param| row[boolean_param] = boolean_string(row[boolean_param]) }
  end

  def boolean_string(string)
    return nil unless string.present?
    AFFIRMATIVE_LETTERS.include?(string[0].downcase) ? 'true' : 'false'
  end
end
