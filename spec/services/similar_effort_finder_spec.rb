require 'rails_helper'

RSpec.describe SimilarEffortFinder, type: :model do
  describe '#initialize' do
    it 'initializes when provided with a sub_split and time_from_start' do
      course = FactoryGirl.build_stubbed(:course)
      split = FactoryGirl.build_stubbed(:split, course: course, id: 110)
      sub_split = {110 => 1}
      time_from_start = 10000
      expect { SimilarEffortFinder.new(sub_split: sub_split, time_from_start: time_from_start, split: split, course: course) }.not_to raise_error
    end

    it 'raises an error if the provided split does not resolve with the provided sub_split' do
      sub_split = {110 => 1}
      time_from_start = 10000
      course = FactoryGirl.build_stubbed(:course)
      split = FactoryGirl.build_stubbed(:split, course: course, id: 220)
      expect { SimilarEffortFinder.new(sub_split: sub_split, time_from_start: time_from_start, split: split, course: course) }
          .to raise_error(/provided sub_split is not contained within the provided split/)
    end
  end

  describe '#efforts' do
    it 'returns an empty ActiveRecord association when no efforts meet the provided criteria' do
      skip 'need FactoryGirl setup that will create a working event with efforts and split_times in memory'
      effort_database = []
      sub_split = {110 => 1}
      time_from_start = 10000
      course = FactoryGirl.build_stubbed(:course)
      split = FactoryGirl.build_stubbed(:split, course: course)
      finder = SimilarEffortFinder.new(sub_split: sub_split, time_from_start: time_from_start, split: split, course: course)
      expect(finder).to receive(:effort_database).and_return(effort_database)
      expect(finder.efforts).to eq(Effort.none)
    end

    it 'returns an ActiveRecord association for the set of efforts that meets the provided criteria' do
      skip 'need FactoryGirl setup that will create a working event with efforts and split_times in memory'
    end
  end

  describe '#events' do
    it 'returns an empty ActiveRecord association when no efforts meet the provided criteria' do
      skip 'need FactoryGirl setup that will create a working event with efforts and split_times in memory'
    end

    it 'returns an ActiveRecord association for the set of unique events relating to efforts that meet the provided criteria' do
      skip 'need FactoryGirl setup that will create a working event with efforts and split_times in memory'
    end
  end
end