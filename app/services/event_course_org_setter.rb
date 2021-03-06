class EventCourseOrgSetter

  attr_reader :resources, :status

  def initialize(args)
    ArgsValidator.validate(params: args,
                           required: [:event, :params],
                           exclusive: [:event, :course, :organization, :params],
                           class: self.class)
    @event = args[:event]
    @course = args[:course]
    @organization = args[:organization]
    @params = args[:params]
    @resources = []
  end

  def set_resources
    ActiveRecord::Base.transaction do
      submitted_resources.each do |resource|
        update_resource(resource)
      end
      raise ActiveRecord::Rollback if status
    end
    self.status ||= :ok
  end

  private

  attr_reader :event, :course, :organization, :params
  attr_writer :response, :status

  def submitted_resources
    [course, organization, event]
  end

  def update_resource(resource)
    if resource.update(class_params(resource.class))
      resource.reload
    else
      self.status = :unprocessable_entity
    end
    self.resources << resource
  end

  def relationships
    result = {event: {course: course, organization: organization}}
    result.default = {}
    result
  end

  def class_params(klass)
    ActionController::Parameters.new(params[symbolized_name(klass)])
        .permit(*"#{klass}Parameters".constantize.permitted)
        .merge(relationships[symbolized_name(klass)])
  end

  def symbolized_class_name(resource)
    symbolized_name(resource.class)
  end

  def symbolized_name(klass)
    klass.name.underscore.to_sym
  end
end
