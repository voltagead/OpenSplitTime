class EffortParameters < BaseParameters

  def self.permitted_query
    enriched_query
  end

  def self.enriched_query
    [:id, :event_id, :participant_id, :wave, :bib_number, :city, :state_code, :age,
     :created_at, :updated_at, :created_by, :updated_by, :first_name, :last_name, :gender,
     :country_code, :birthdate, :data_status, :start_offset, :dropped_split_id, :concealed,
     :beacon_url, :report_url, :photo_url, :dropped_lap, :laps_required, :event_start_time,
     :final_split_name, :final_lap_distance, :final_lap, :final_split_id, :final_bitkey, :final_time,
     :final_split_time_id, :stopped_split_time_id, :stopped_lap, :stopped_split_id, :stopped_bitkey,
     :stopped_time, :final_lap_complete, :course_distance, :started, :laps_started, :laps_finished,
     :final_distance, :finished, :stopped, :dropped, :overall_rank, :gender_rank]
  end

  def self.permitted
    [:id, :event_id, :participant_id, :first_name, :last_name, :gender, :wave, :bib_number, :age, :birthdate,
     :city, :state_code, :country_code, :finished, :concealed, :start_time, :start_offset,
     :beacon_url, :report_url, :photo_url, :phone, :email,
     split_times_attributes: [*SplitTimeParameters.permitted]]
  end

  def self.mapping
    {first: :first_name, firstname: :first_name, last: :last_name, lastname: :last_name, state: :state_code,
     country: :country_code, sex: :gender, bib: :bib_number}
  end
end
