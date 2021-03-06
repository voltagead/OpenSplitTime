class CourseShowView

  attr_reader :course, :events
  delegate :name, :description, to: :course

  def initialize(course, params)
    @course = course
    @params = params
    @events = course.events.select_with_params(params[:search]).to_a
  end

  def ordered_splits
    @ordered_splits ||= course.ordered_splits
  end

  def course_id
    course.id
  end

  def splits_count
    ordered_splits.size
  end

  def events_count
    events.size
  end

  def latitude_center
    ordered_splits.pluck(:latitude).compact.mean
  end

  def longitude_center
    ordered_splits.pluck(:longitude).compact.mean
  end

  def zoom
    9
  end

  def course_has_location_data?
    ordered_splits.where.not(latitude: nil).where.not(longitude: nil).present?
  end

  def view_text
    params[:view] == 'splits' ? 'splits' : 'events'
  end

  def simple?
    splits_count <= 2
  end

  private

  attr_reader :params

end