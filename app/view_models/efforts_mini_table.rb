class EffortsMiniTable

  def initialize(effort_ids_param)
    effort_ids = effort_ids_param.split(',').flatten
    @efforts = Effort.where(id: effort_ids)
  end

  def effort_rows
    @effort_rows ||= efforts.map { |effort| EffortRow.new(effort: effort) }
  end

  private

  attr_reader :efforts
end