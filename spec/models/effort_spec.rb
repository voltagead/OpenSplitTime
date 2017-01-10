require 'rails_helper'

# t.integer  "event_id",                  null: false
# t.integer  "participant_id"
# t.string   "wave"
# t.integer  "bib_number"
# t.string   "city",           limit: 64
# t.string   "state_code",     limit: 64
# t.integer  "age"
# t.boolean  "dropped_split_id"
# t.string   "first_name"
# t.string   "last_name"
# t.integer  "gender"
# t.string   "country_code",   limit: 2
# t.date     "birthdate"
# t.integer  "data_status"
# t.integer  "start_offset"

RSpec.describe Effort, type: :model do
  it_behaves_like 'data_status_methods'
  it { is_expected.to strip_attribute(:first_name).collapse_spaces }
  it { is_expected.to strip_attribute(:last_name).collapse_spaces }
  it { is_expected.to strip_attribute(:state_code).collapse_spaces }
  it { is_expected.to strip_attribute(:country_code).collapse_spaces }

  describe 'validations' do
    let(:course) { Course.create!(name: 'Test Course') }
    let(:event) { Event.create!(course: course, name: 'Test Event', start_time: '2012-08-08 05:00:00') }
    let(:location1) { Location.create!(name: 'Mountain Town', elevation: 2400, latitude: 40.1, longitude: -105) }
    let(:location2) { Location.create!(name: 'Mountain Hideout', elevation: 2900, latitude: 40.3, longitude: -105.05) }
    let(:participant) { Participant.create!(first_name: 'Joe', last_name: 'Hardman',
                                            gender: 'male', birthdate: '1989-12-15',
                                            city: 'Boulder', state_code: 'CO', country_code: 'US') }

    it 'is valid when created with an event_id, first_name, last_name, and gender' do
      Effort.create!(event: event, first_name: 'David', last_name: 'Goliath', gender: 'male')

      expect(Effort.all.count).to(equal(1))
      expect(Effort.first.event).to eq(event)
      expect(Effort.first.last_name).to eq('Goliath')
    end

    it 'is invalid without an event_id' do
      effort = Effort.new(event: nil, first_name: 'David', last_name: 'Goliath', gender: 'male')
      expect(effort).not_to be_valid
      expect(effort.errors[:event_id]).to include("can't be blank")
    end

    it 'is invalid without a first_name' do
      effort = Effort.new(event: event, first_name: nil, last_name: 'Appleseed', gender: 'male')
      expect(effort).not_to be_valid
      expect(effort.errors[:first_name]).to include("can't be blank")
    end

    it 'is invalid without a last_name' do
      effort = Effort.new(first_name: 'Johnny', last_name: nil, gender: 'male')
      expect(effort).not_to be_valid
      expect(effort.errors[:last_name]).to include("can't be blank")
    end

    it 'is invalid without a gender' do
      effort = Effort.new(first_name: 'Johnny', last_name: 'Appleseed', gender: nil)
      expect(effort).not_to be_valid
      expect(effort.errors[:gender]).to include("can't be blank")
    end

    it 'does not permit more than one effort by a participant in a given event' do
      Effort.create!(event: event, first_name: 'David', last_name: 'Goliath', gender: 'male',
                     participant: participant)
      effort = Effort.new(event: event, first_name: 'David', last_name: 'Goliath', gender: 'male',
                          participant: participant)
      expect(effort).not_to be_valid
      expect(effort.errors[:participant_id]).to include('has already been taken')
    end

    it 'permits more than one effort in a given event with unassigned participants' do
      Effort.create!(event: event, first_name: 'David', last_name: 'Goliath', gender: 'male',
                     participant: nil)
      effort = Effort.new(event: event, first_name: 'Betty', last_name: 'Boop', gender: 'female',
                          participant: nil)
      expect(effort).to be_valid
    end

    it 'does not permit duplicate bib_numbers within a given event' do
      Effort.create!(event: event, first_name: 'David', last_name: 'Goliath', gender: 'male', bib_number: 20)
      effort = Effort.new(event: event, participant_id: 2, bib_number: 20)
      expect(effort).not_to be_valid
      expect(effort.errors[:bib_number]).to include('has already been taken')
    end
  end

  describe 'within_time_range' do
    before do

      @course = Course.create!(name: 'Test Course 100')
      @event = Event.create!(name: 'Test Event 2015', course: @course, start_time: '2015-07-01 06:00:00')

      @location1 = Location.create!(name: 'Mountain Town', elevation: 2400, latitude: 40.1, longitude: -105)
      @location2 = Location.create!(name: 'Mountain Hideout', elevation: 2900, latitude: 40.3, longitude: -105.05)

      @effort1 = Effort.create!(event: @event, bib_number: 99, city: 'Vancouver', state_code: 'BC', country_code: 'CA', age: 50, first_name: 'Jen', last_name: 'Huckster', gender: 'female')
      @effort2 = Effort.create!(event: @event, bib_number: 12, city: 'Boulder', state_code: 'CO', country_code: 'US', age: 23, first_name: 'Joe', last_name: 'Hardman', gender: 'male')
      @effort3 = Effort.create!(event: @event, bib_number: 150, city: 'Nantucket', state_code: 'MA', country_code: 'US', age: 26, first_name: 'Jane', last_name: 'Rockstar', gender: 'female')

      @split1 = Split.create!(course: @course, location: @location1, base_name: 'Test Starting Line', distance_from_start: 0, vert_gain_from_start: 0, vert_loss_from_start: 0, kind: 0)
      @split3 = Split.create!(course: @course, location: @location2, base_name: 'Test Aid Station', distance_from_start: 6000, sub_split_bitmap: 65, vert_gain_from_start: 500, vert_loss_from_start: 0, kind: 2)
      @split4 = Split.create!(course: @course, location: @location1, base_name: 'Test Finish Line', distance_from_start: 10000, vert_gain_from_start: 700, vert_loss_from_start: 700, kind: 1)

      @event.splits << @course.splits

      SplitTime.create!(effort: @effort1, split: @split1, bitkey: SubSplit::IN_BITKEY, time_from_start: 0)
      SplitTime.create!(effort: @effort1, split: @split3, bitkey: SubSplit::IN_BITKEY, time_from_start: 4000)
      SplitTime.create!(effort: @effort1, split: @split3, bitkey: SubSplit::OUT_BITKEY, time_from_start: 4100)
      SplitTime.create!(effort: @effort1, split: @split4, bitkey: SubSplit::IN_BITKEY, time_from_start: 8000)
      SplitTime.create!(effort: @effort2, split: @split1, bitkey: SubSplit::IN_BITKEY, time_from_start: 0)
      SplitTime.create!(effort: @effort2, split: @split3, bitkey: SubSplit::IN_BITKEY, time_from_start: 5000)
      SplitTime.create!(effort: @effort2, split: @split3, bitkey: SubSplit::OUT_BITKEY, time_from_start: 5100)
      SplitTime.create!(effort: @effort2, split: @split4, bitkey: SubSplit::IN_BITKEY, time_from_start: 9000)
      SplitTime.create!(effort: @effort3, split: @split1, bitkey: SubSplit::IN_BITKEY, time_from_start: 0)
      SplitTime.create!(effort: @effort3, split: @split3, bitkey: SubSplit::IN_BITKEY, time_from_start: 3000)
      SplitTime.create!(effort: @effort3, split: @split3, bitkey: SubSplit::OUT_BITKEY, time_from_start: 3100)
      SplitTime.create!(effort: @effort3, split: @split4, bitkey: SubSplit::IN_BITKEY, time_from_start: 7500)
    end

    it 'returns only those efforts for which the finish time is between the parameters provided' do
      efforts = Effort.all
      expect(efforts.within_time_range(7800, 8200).count).to eq(1)
      expect(efforts.within_time_range(5000, 10000).count).to eq(3)
      expect(efforts.within_time_range(10000, 20000).count).to eq(0)
    end
  end

  describe 'approximate_age_today' do
    it 'returns nil if age is not present' do
      effort = FactoryGirl.build(:effort)
      expect(effort.approximate_age_today).to be_nil
    end

    it 'calculates approximate age at the current time based on age at time of effort' do
      age = 40
      event_start_time = DateTime.new(2010, 1, 1, 0, 0, 0)
      years_since_effort = Time.now.year - event_start_time.year
      effort = FactoryGirl.build(:effort, age: age)
      expect(effort).to receive(:event_start_time).and_return(event_start_time)
      expect(effort.approximate_age_today).to eq(age + years_since_effort)
    end

    it 'functions properly for future events' do
      age = 40
      event_start_time = DateTime.new(2030, 1, 1, 0, 0, 0)
      years_since_effort = Time.now.year - event_start_time.year
      effort = FactoryGirl.build(:effort, age: age)
      expect(effort).to receive(:event_start_time).and_return(event_start_time)
      expect(effort.approximate_age_today).to eq(age + years_since_effort)
    end
  end

  describe 'time_in_aid' do
    it 'returns nil when the split has no split_times' do
      split_times = SplitTime.none
      effort = Effort.new(first_name: 'Joe', last_name: 'Tester', gender: 'male')
      split = FactoryGirl.build(:split)
      expect(effort).to receive(:ordered_split_times).and_return(split_times)
      expect(effort.time_in_aid(split)).to be_nil
    end

    it 'returns nil when the split has only one split_time' do
      split_times = FactoryGirl.build_stubbed_list(:split_times_in_only, 4)
      effort = Effort.new(first_name: 'Joe', last_name: 'Tester', gender: 'male')
      split = FactoryGirl.build(:split, id: 202)
      matching_split_times = split_times.select { |split_time| split_time.split_id == split.id }
      expect(matching_split_times.count).to eq(1)
      expect(effort).to receive(:ordered_split_times).and_return(matching_split_times)
      expect(effort.time_in_aid(split)).to be_nil
    end

    it 'returns the difference between in and out times when the split has in and out split_times' do
      split_times = FactoryGirl.build_stubbed_list(:split_times_in_out, 4)
      effort = Effort.new(first_name: 'Joe', last_name: 'Tester', gender: 'male')
      split = FactoryGirl.build(:split, id: 102)
      matching_split_times = split_times.select { |split_time| split_time.split_id == split.id }
      expect(matching_split_times.count).to eq(2)
      expect(effort).to receive(:ordered_split_times).and_return(matching_split_times)
      expect(effort.time_in_aid(split)).to eq(100)
    end
  end

  describe 'total_time_in_aid' do
    it 'returns zero when the event has no splits' do
      split_times = []
      effort = FactoryGirl.build(:effort)
      expect(effort).to receive(:ordered_split_times).and_return(split_times)
      expect(effort.total_time_in_aid).to eq(0)
    end

    it 'returns zero when the event has only "in" splits' do
      split_times = FactoryGirl.build_stubbed_list(:split_times_in_only, 12)
      effort = FactoryGirl.build(:effort)
      expect(effort).to receive(:ordered_split_times).and_return(split_times)
      expect(effort.total_time_in_aid).to eq(0)
    end

    it 'correctly calculates time in aid based on times in and out of splits' do
      split_times = FactoryGirl.build_stubbed_list(:split_times_in_out, 12)
      effort = FactoryGirl.build(:effort)
      expect(effort).to receive(:ordered_split_times).and_return(split_times)
      expect(effort.total_time_in_aid).to eq(500)
    end
  end
end