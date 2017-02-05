class EffortProgressFramework

  delegate :bib_number, :full_name, :bio_historic, to: :effort

  def initialize(args)
    @effort = args[:effort]
    @event_framework = args[:event_framework]
    post_initialize(args)
  end

  def post_initialize(args)
    nil
  end

  def effort_id
    effort.id
  end

  def last_reported_name
    lap_split_name(last_reported_time_point)
  end

  def due_next_name
    lap_split_name(due_next_time_point)
  end

  def last_reported_day_and_time
    effort.day_and_time(effort.final_time)
  end

  def due_next_day_and_time
    effort.day_and_time(time_from_start_to_next)
  end

  private

  attr_reader :effort, :event_framework
  delegate :lap_splits, :indexed_lap_splits, :multiple_laps?, :time_points,
           :times_container, to: :event_framework

  def last_reported_split_time
    SplitTime.new(effort: effort,
                  time_point: last_reported_time_point,
                  time_from_start: effort.final_time)
  end

  def time_from_start_to_next
    predicted_upcoming_time && (predicted_upcoming_time + effort.final_time)
  end

  def predicted_upcoming_time
    @predicted_upcoming_time ||= predicted_segment_time(upcoming_segment)
  end

  def predicted_segment_time(segment)
    segment.end_point.out? ? nil : TimePredictor.segment_time(segment: segment,
                                                              effort: effort,
                                                              lap_splits: lap_splits,
                                                              completed_split_time: last_reported_split_time,
                                                              times_container: times_container)
  end

  def upcoming_segment
    Segment.new(begin_point: last_reported_time_point, end_point: due_next_time_point)
  end

  def last_reported_time_point
    @last_reported_time_point ||= TimePoint.new(effort.final_lap, effort.final_split_id, effort.final_bitkey)
  end

  def due_next_time_point
    @due_next_time_point ||= time_points[last_reported_time_point_index + 1]
  end

  def last_reported_time_point_index
    time_points.index(last_reported_time_point)
  end

  def lap_split_name(time_point)
    lap_split = indexed_lap_splits[time_point.lap_split_key]
    bitkey = time_point.bitkey
    multiple_laps? ? lap_split.name(bitkey) : lap_split.name_without_lap(bitkey)
  end
end