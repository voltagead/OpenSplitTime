class EffortRow
  include PersonalInfo

  attr_reader :overall_place, :gender_place, :finish_status, :start_time_from_params
  delegate :id, :first_name, :last_name, :gender, :bib_number, :age, :state_code, :country_code, :data_status,
           :bad?, :questionable?, :good?, :confirmed?, :segment_time, to: :effort

  def initialize(effort, options = {})
    @effort = effort
    @overall_place = options[:overall_place]
    @gender_place = options[:gender_place]
    @finish_status = options[:finish_status]
    @start_time_from_params = options[:start_time]
  end

  def year
    return start_time_from_params.try(:to_datetime).year if start_time_from_params
    effort.start_time ? effort.start_time.year : nil
  end

  def finish_time
    (finish_status && finish_status.is_a?(Numeric)) ? finish_status : nil
  end

  private

  attr_reader :effort

end