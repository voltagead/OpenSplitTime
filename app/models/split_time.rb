class SplitTime < ActiveRecord::Base
  include Auditable
  enum data_status: [:bad, :questionable, :good, :confirmed] # nil = unknown, 0 = bad, 1 = questionable, 2 = good, 3 = confirmed
  belongs_to :effort
  belongs_to :split

  scope :valid_status, -> { where(data_status: [nil, data_statuses[:good], data_statuses[:confirmed]]) }
  scope :ordered, -> { includes(:split).order('splits.distance_from_start, splits.sub_order') }
  scope :finish, -> { includes(:split).where(splits: {kind: Split.kinds[:finish]}) }
  scope :start, -> { includes(:split).where(splits: {kind: Split.kinds[:start]}) }
  scope :base, -> { includes(:split).where(splits: {sub_order: 0}) }

  before_validation :delete_if_blank
  after_update :set_effort_data_status, if: :time_from_start_changed?

  validates_presence_of :effort_id, :split_id, :time_from_start
  validates :data_status, inclusion: {in: SplitTime.data_statuses.keys}, allow_nil: true
  validates_uniqueness_of :split_id, scope: :effort_id,
                          :message => "only one of any given split permitted within an effort"
  validate :course_is_consistent, unless: 'effort.nil? | split.nil?' # TODO fix tests so that .nil? checks are not necessary

  def course_is_consistent
    if effort.event.course_id != split.course_id
      errors.add(:effort_id, "the effort.event.course_id does not resolve with the split.course_id")
      errors.add(:split_id, "the effort.event.course_id does not resolve with the split.course_id")
    end
  end

  def set_effort_data_status
    effort.set_data_status
  end

 def elapsed_time
    return nil if time_from_start.nil?
    seconds = time_from_start % 60
    minutes = (time_from_start / 60) % 60
    hours = time_from_start / (60 * 60)
    format("%02d:%02d:%02d", hours, minutes, seconds)
  end

  alias_method :formatted_time_hhmmss, :elapsed_time

  def elapsed_time=(elapsed_time)
    if elapsed_time.present?
      units = %w(hours minutes seconds)
      self.time_from_start = elapsed_time.split(':').map.with_index { |x, i| x.to_i.send(units[i]) }.reduce(:+).to_i
    else
      self.time_from_start = nil
    end
  end

  def day_and_time
    return nil if time_from_start.nil?
    event_start_time + effort_start_offset + time_from_start
  end

  def day_and_time=(absolute_time)
    if absolute_time.present?
      self.time_from_start = absolute_time - event_start_time - effort_start_offset
    else
      self.time_from_start = nil
    end
  end

  def military_time=(military_time)
    if military_time.present?
      units = %w(hours minutes seconds)
      seconds_in_day = military_time.split(':').map.with_index { |x, i| x.to_i.send(units[i]) }.reduce(:+).to_i
      self.day_and_time = likely_intended_time(seconds_in_day)
    else
      self.day_and_time = nil
    end
  end

  def waypoint_group
    splits = split.waypoint_group
    split_time_array = []
    splits.each do |split|
      split_time_array << split.split_times.where(effort: effort).first
    end
    split_time_array # Includes nil values when no split_time is associated with members of the split.waypoint_group
  end

  def self.confirmed!
    all.each { |split_time| split_time.confirmed! }
  end

  def self.good!
    all.each { |split_time| split_time.good! }
  end

  private

  def event_start_time
    effort.event_start_time
  end

  def effort_start_offset
    effort.start_offset
  end

  def likely_intended_time(seconds_in_day)
    expected_time = effort.due_next_when
    working_datetime = event_start_time.beginning_of_day + seconds_in_day
    working_datetime + ((((working_datetime - expected_time) * -1) / 1.day).round(0) * 1.day)
  end

  def delete_if_blank
    self.delete if elapsed_time == ""
  end

end