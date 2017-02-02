class AidStationDetail

  attr_reader :aid_station
  delegate :course, :race, to: :event
  delegate :event, :split, :split_id, :open_time, :close_time, :status, :captain_name, :comms_crew_names,
           :comms_frequencies, :current_issues, to: :aid_station
  delegate :expected_day_and_time, :prior_valid_display_data, :next_valid_display_data, to: :live_event

  EFFORT_CATEGORIES = [:started, :recorded_in, :recorded_out, :dropped_here, :in_aid, :missed, :expected]
  IN_BITKEY = SubSplit::IN_BITKEY
  OUT_BITKEY = SubSplit::OUT_BITKEY

  def initialize(args)
    ArgsValidator.validate(params: args,
                           required: :aid_station,
                           exclusive: [:aid_station, :event_data],
                           class: self.class)
    @aid_station = args[:aid_station]
    @live_event = args[:event_data]
  end

  def efforts_recorded_in_ids
    split_times.select { |st| st.bitkey == IN_BITKEY }.map(&:effort_id)
  end

  def efforts_recorded_out_ids
    split_times.select { |st| st.bitkey == OUT_BITKEY }.map(&:effort_id)
  end

  def efforts_dropped_here_ids
    efforts_dropped.select { |effort| effort.dropped_split_id == split_id}.map(&:id)
  end

  def efforts_in_aid_ids
    efforts_recorded_in_ids - efforts_recorded_out_ids
  end

  def efforts_missed_ids
    efforts_not_recorded_ids - efforts_recorded_later_ids
  end

  def efforts_expected_ids
    efforts_not_recorded_ids - efforts_missed_ids - efforts_dropped_ids
  end

  def efforts_not_recorded_ids
    efforts_started_ids - efforts_recorded_in_ids - efforts_recorded_out_ids
  end

  def efforts_recorded_later_ids
    efforts.select { |effort| ordered_split_ids.index(effort.final_split_id) > ordered_split_ids.index(split_id) }
  end

  def efforts_recorded_out
    @efforts_recorded_out ||=
        efforts_started.select { |effort| indexed_split_times[effort.id].map(&:bitkey).include?(SubSplit::OUT_BITKEY) }
  end

  def efforts_dropped_here
    @efforts_dropped_here ||= efforts_dropped.select { |effort| effort.dropped_split_id == split_id }
  end

  def efforts_in_aid
    @efforts_in_aid ||= efforts_recorded_in - efforts_recorded_out
  end

  def efforts_missed
    @efforts_missed ||= efforts_not_recorded.select { |effort| recorded_later(effort) }
  end

  def efforts_expected
    @efforts_expected ||= efforts_not_recorded - efforts_missed - efforts_dropped
  end

  EFFORT_CATEGORIES.each do |category|
    define_method("efforts_#{category}_count") do
      method("efforts_#{category}").call.size
    end
  end

  EFFORT_CATEGORIES.each do |category|
    define_method("efforts_#{category}_ids") do
      method("efforts_#{category}").call.map(&:id)
    end
  end

  EFFORT_CATEGORIES.each do |category|
    define_method("efforts_#{category}_table_title") do
      count = method("efforts_#{category}_count").call
      "#{persons(count)} #{is_are(count)} #{category} at #{aid_station.split_name}"
    end
  end

  def split_name
    split.base_name
  end

  def event_name
    event.name
  end

  def course_name
    course.name
  end

  def race_name
    race && race.name
  end

  def recorded_in_day_and_time(effort)
    recorded_day_and_time(effort, sub_split_in)
  end

  def recorded_out_day_and_time(effort)
    recorded_day_and_time(effort, sub_split_out)
  end

  private

  attr_reader :event_data
  delegate :sub_split_in, :sub_split_out, to: :split
  delegate :ordered_split_ids, :efforts_started, :efforts_dropped, :efforts_finished,
           :efforts_in_progress, to: :event_data

  def split_times
    event.split_times.recorded_at_aid(aid_station.id)
  end

  def efforts_not_recorded
    @efforts_not_recorded ||= efforts_started - efforts_recorded_in - efforts_recorded_out
  end

  def start_split_id
    ordered_split_ids.first
  end

  def recorded_later(effort)
    ordered_split_ids.index(effort.final_split_id) > ordered_split_ids.index(split_id)
  end

  def recorded_day_and_time(effort, sub_split)
    split_time = indexed_split_times[effort.id].index_by(&:sub_split)[sub_split]
    split_time && effort.start_time + split_time.time_from_start
  end

  def persons(number)
    number == 1 ? "#{number} person" : "#{number} people"
  end

  def was_were(number)
    number == 1 ? 'was' : 'were'
  end

  def is_are(number)
    number == 1 ? 'is' : 'are'
  end

  def has_have(number)
    number == 1 ? 'has' : 'have'
  end
end