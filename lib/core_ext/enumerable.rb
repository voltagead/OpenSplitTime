module Enumerable
  def count_by(&block)
    Hash[group_by(&block).map { |k, v| [k, v.count] }]
  end

  def count_each
    count_by { |e| e }
  end
end