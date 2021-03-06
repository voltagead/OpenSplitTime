class Participant < ActiveRecord::Base

  include Auditable
  include Concealable
  include PersonalInfo
  include Searchable
  include SetOperations
  include Matchable
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged
  strip_attributes collapse_spaces: true
  phony_normalize :phone, default_country_code: 'US'

  enum gender: [:male, :female]
  has_many :subscriptions, dependent: :destroy
  has_many :followers, through: :subscriptions, source: :user
  has_many :efforts
  belongs_to :claimant, class_name: 'User', foreign_key: 'user_id'

  attr_accessor :suggested_match

  # Outer joins are required to find participants having no associated efforts
  scope :with_age_and_effort_count, -> { select(SQL[:age_and_effort_count])
                                             .joins('LEFT OUTER JOIN efforts ON (efforts.participant_id = participants.id)')
                                             .joins('LEFT OUTER JOIN events ON (events.id = efforts.event_id)')
                                             .group('participants.id') }
  scope :ordered_by_name, -> { order(:last_name, :first_name) }

  SQL = {age_and_effort_count: 'participants.*, COUNT(efforts.id) as effort_count, ROUND(AVG((extract(epoch from(current_date - events.start_time))/60/60/24/365.25) + efforts.age)) as participant_age',
         ages_from_events: '((extract(epoch from(current_date - events.start_time))/60/60/24/365.25) + efforts.age)'}

  before_validation :set_topic_resource
  before_destroy :delete_topic_resource
  validates_presence_of :first_name, :last_name, :gender
  validates :email, allow_blank: true, length: {maximum: 105},
            uniqueness: {case_sensitive: false},
            format: {with: VALID_EMAIL_REGEX}
  validates :phone, phony_plausible: true

  # This method needs to extract ids and run a new search to remain compatible
  # with the scope `.with_age_and_effort_count`.
  def self.search(param)
    return none unless param && param.size > 2
    parser = SearchStringParser.new(param)
    ids = country_state_name_search(parser).ids
    Participant.where(id: ids)
  end

  def self.age_matches(age_param)
    return none unless age_param.is_a?(Numeric)
    threshold = 2 # Allow for some inaccuracy in reporting, rounding errors, etc.
    age_hash = approximate_ages_today.merge(exact_ages_today)
                   .reject { |_, age| (age - age_param).abs > threshold }
    self.where(id: age_hash.keys)
  end

  def self.columns_to_pull_from_model
    [:first_name, :last_name, :gender, :birthdate, :email, :phone, :photo_url, :created_by]
  end

  def self.approximate_ages_today # Returns a hash of {participant_id => approximate age}
    joins(:efforts => :event).group('participants.id').average(SQL[:ages_from_events]).transform_values(&:to_f)
  end

  private_class_method :approximate_ages_today

  def slug_candidates
    [:full_name, [:full_name, :state_and_country], [:full_name, :state_and_country, Date.today.to_s],
     [:full_name, :state_and_country, Date.today.to_s, Time.current.strftime('%H:%M:%S')]]
  end

  def set_topic_resource
    self.topic_resource_key = SnsTopicManager.generate(participant: self) if generate_new_topic_resource?
  end

  def delete_topic_resource
    if topic_resource_key.present?
      SnsTopicManager.delete(participant: self)
      self.topic_resource_key = nil
    end
  end

  def approximate_age_today
    average = efforts.joins(:event).average(SQL[:ages_from_events]).to_f
    average == 0 ? nil : average
  end

  def unclaimed?
    claimant.nil?
  end

  def claimed?
    claimant.present?
  end

  def add_follower(user)
    followers << user
  end

  def remove_follower(user)
    followers.delete(user)
  end

  def should_be_concealed?
    !efforts.visible.present?
  end

  # Methods related to matching and merging efforts with participants

  def most_likely_duplicate
    possible_matching_participants.first
  end

  def associate_effort(effort)
    if AttributePuller.pull_attributes!(self, effort)
      if effort.update(participant: self)
        logger.info "Effort #{effort.name} was associated with Participant #{self.name}"
        true
      else
        logger.info "Effort #{effort.name} could not be associated with Participant #{self.name}: " +
                        "#{effort.errors.full_messages}, #{self.errors.full_messages}"
        false
      end
    end
  end

  def merge_with(target)
    target.reload
    if AttributePuller.pull_attributes!(self, target)
      efforts << target.efforts
      target.destroy
    end
  end

  private

  def generate_new_topic_resource?
    topic_resource_key.nil? && slug.present?
  end
end
