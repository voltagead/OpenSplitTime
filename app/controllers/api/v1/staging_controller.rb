class Api::V1::StagingController < ApiController
  before_action :set_event, except: [:post_event_course_org]
  before_action :find_or_initialize_event, only: [:post_event_course_org]
  before_action :authorize_event

  # GET /api/v1/staging/:staging_id/get_countries
  def get_countries
    render json: {countries: Geodata.standard_countries_subregions}
  end

  # Returns location data for all splits on any course that falls
  # entirely or partially within the provided boundaries, but excludes splits on
  # the course of the provided event.

  # GET /api/vi/staging/:staging_id/get_locations?west=&east=&south=&north=
  def get_locations
    splits = SplitLocationFinder.splits(params).where.not(course_id: @event.course_id)
    render json: splits, each_serializer: SplitLocationSerializer
  end

  # Creates or updates the given event, course, and organization
  # and associates the event with the course and organization,
  # all in a single transaction.

  # POST /api/v1/staging/:staging_id/post_event_course_org
  def post_event_course_org
    course = Course.find_or_initialize_by(id: params[:course][:id])
    authorize course unless course.new_record?

    organization = Organization.find_or_initialize_by(id: params[:organization][:id])
    authorize organization unless organization.new_record?

    setter = EventCourseOrgSetter.new(event: @event, course: course, organization: organization, params: params)
    setter.set_resources
    if setter.status == :ok
      render json: setter.resources.map { |resource| [resource.class.to_s.underscore, resource.to_json] }.to_h, status: setter.status
    else
      render json: {errors: setter.resources.map { |resource| jsonapi_error_object(resource) }}, status: setter.status
    end
  end

  # Sets the concealed status of the event and related organization, efforts, and participants.
  # param :status must be set to 'public' or 'private'

  # PATCH /api/v1/staging/:staging_id/update_event_visibility
  def update_event_visibility
    setter = EventConcealedSetter.new(event: @event)
    if params[:status] == 'public'
      setter.make_public
    elsif params[:status] == 'private'
      setter.make_private
    else
      render json: {errors: ['invalid status'], detail: 'request must include status: public or status: private'}, status: :bad_request and return
    end
    render json: setter.response, status: setter.status
  end

  private

  def set_event
    @event = params[:staging_id].uuid? ?
        Event.find_by!(staging_id: params[:staging_id]) :
        Event.friendly.find(params[:staging_id])
  end

  def find_or_initialize_event
    @event = Event.find_or_initialize_by(staging_id: params[:staging_id])
    unless @event.staging_id
      render json: {errors: ['invalid uuid'], detail: 'provided staging_id is not a valid uuid'}, status: :bad_request
    end
  end

  def authorize_event
    authorize @event
  end
end
