# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) can be set in the file .env file.

User.create!(first_name: 'Admin', last_name: 'User', role: :admin, email: 'user@example.com', password: 'password', confirmed_at: Time.now)
User.create!(first_name: 'Test', last_name: 'User', role: :user, email: 'tester@example.com', password: 'password', confirmed_at: Time.now)
User.create!(first_name: 'Third', last_name: 'User', role: :user, email: 'thirduser@example.com', password: 'password', confirmed_at: Time.now)
User.create!(first_name: 'Fourth', last_name: 'User', role: :user, email: 'fourthuser@example.com', password: 'password', confirmed_at: Time.now)

Course.create(name: 'Test Course CCW')
Course.create(name: 'Another Course')
Course.create(name: 'Nolans 140')
Course.create(name: 'Hardrock CCW', description: 'Counter-clockwise Hardrock 100 course, starting in Silverton, going to Sherman, over Handies Peak, to Ouray, Telluride, and back to Silverton')

Organization.create(name: 'Slo Mo 100')
Organization.create(name: 'Frozen Lips 100')
Organization.create(name: 'Hardly Rocker 100')
Organization.create(name: 'Hardrock 100')

Event.create(course_id: 2, organization_id: 3, name: 'Hardly Rocker 2010', start_time: "2010-08-10 06:00:00", laps_required: 1)
Event.create(course_id: 2, organization_id: 2, name: 'Frozen Lips 2015', start_time: "2015-05-31 07:00:00", laps_required: 1)
Event.create(course_id: 1, organization_id: nil, name: 'Test Event', start_time: "2012-08-08 05:00:00", laps_required: 1)
Event.create(course_id: 4, organization_id: 4, name: 'Hardrock 100 2015', start_time: "2015-07-10 06:00:00", laps_required: 1)

Participant.create(first_name: 'Joe', last_name: 'Hardman', gender: 'male', birthdate: "1989-12-15", city: 'Boulder', state_code: 'CO', country_code: 'US', email: 'hardman@gmail.com', phone: nil)
Participant.create(first_name: 'Jane', last_name: 'Rockstar', gender: 'female', birthdate: "1985-09-20", city: 'Seattle', state_code: 'WA', country_code: 'US', email: nil, phone: '206-977-9777')
Participant.create(first_name: 'Basil', last_name: 'Smith', gender: 'male', birthdate: "1995-04-31", city: 'Guildford', state_code: 'SRY', country_code: 'GB', email: 'basil@uk.gov')
Participant.create(first_name: 'Jen', last_name: 'Huckster', gender: 'female', birthdate: nil, city: 'Vancouver', state_code: 'BC', country_code: 'CA', email: 'jane@canuck.com', phone: '804-888-5555')

Effort.create(event_id: 3, participant_id: 4, wave: nil, bib_number: 99, city: 'Vancouver', state_code: 'BC', country_code: 'CA', age: 50, start_time: "2012-08-08 05:00:00", first_name: 'Jen', last_name: 'Huckster', gender: 'female')
Effort.create(event_id: 3, participant_id: 1, wave: nil, bib_number: 12, city: 'Boulder', state_code: 'CO', country_code: 'US', age: 23, start_time: "2012-08-08 05:00:00", first_name: 'Joe', last_name: 'Hardman', gender: 'male')
Effort.create(event_id: 1, participant_id: 2, wave: nil, bib_number: 1775, city: 'Atlanta', state_code: 'GA', country_code: 'US', age: 24, start_time: "2010-08-10 06:00:00", first_name: 'Jane', last_name: 'Rockstar', gender: 'female')
Effort.create(event_id: 2, participant_id: 3, wave: nil, bib_number: 44, city: 'Guildford', state_code: 'SRY', country_code: 'GB', age: 20, start_time: "2015-05-31 07:00:00", first_name: 'Basil', last_name: 'Smith', gender: 'male')
Effort.create(event_id: 1, participant_id: 3, wave: nil, bib_number: 66, city: 'Cranleigh', state_code: 'SRY', country_code: 'GB', age: 15, start_time: "2010-08-10 06:00:00", first_name: 'Basil', last_name: 'Smith', gender: 'male')
Effort.create(event_id: 3, participant_id: 2, wave: nil, bib_number: 150, city: 'Nantucket', state_code: 'MA', country_code: 'US', age: 26, start_time: "2012-08-08 05:00:00", first_name: 'Jane', last_name: 'Rockstar', gender: 'female')

Split.create(course_id: 1, base_name: 'Test Starting Line', distance_from_start: 0, vert_gain_from_start: 0, vert_loss_from_start: 0, kind: 0, elevation: 2400, latitude: 40.1, longitude: -105)
Split.create(course_id: 1, base_name: 'Test Aid Station 1', distance_from_start: 4000, sub_split_bitmap: 65, vert_gain_from_start: 400, vert_loss_from_start: 0, kind: 2, elevation: 3000, latitude: 40.2, longitude: -105.4)
Split.create(course_id: 1, base_name: 'Test Aid Station 2', distance_from_start: 7000, sub_split_bitmap: 65, vert_gain_from_start: 700, vert_loss_from_start: 0, kind: 2, elevation: 3000, latitude: 40.2, longitude: -105.4)
Split.create(course_id: 1, base_name: 'Test Finish Line', distance_from_start: 10000, vert_gain_from_start: 1000, vert_loss_from_start: 1000, kind: 1, elevation: 2800, latitude: 40.05, longitude: -105.2)
Split.create(course_id: 2, base_name: 'Another Starting Line', distance_from_start: 0, vert_gain_from_start: 0, vert_loss_from_start: 0, kind: 0, elevation: 200, latitude: -43, longitude: 146.3)
Split.create(course_id: 2, base_name: 'Another Aid Station', distance_from_start: 6000, sub_split_bitmap: 65, vert_gain_from_start: 500, vert_loss_from_start: 0, kind: 2, elevation: 250, latitude: -43.1, longitude: 146.4)
Split.create(course_id: 2, base_name: 'Another Finish Line', distance_from_start: 10000, vert_gain_from_start: 700, vert_loss_from_start: 700, kind: 1, elevation: 300, latitude: -43.2, longitude: 146.2)

SplitTime.create(effort_id: 1, split_id: 1, lap: 1, time_from_start: 0)
SplitTime.create(effort_id: 1, split_id: 2, lap: 1, time_from_start: 4000)
SplitTime.create(effort_id: 1, split_id: 3, lap: 1, time_from_start: 4100)
SplitTime.create(effort_id: 1, split_id: 4, lap: 1, time_from_start: 8000)
SplitTime.create(effort_id: 2, split_id: 1, lap: 1, time_from_start: 0)
SplitTime.create(effort_id: 2, split_id: 2, lap: 1, time_from_start: 5000)
SplitTime.create(effort_id: 2, split_id: 3, lap: 1, time_from_start: 5100)
SplitTime.create(effort_id: 2, split_id: 4, lap: 1, time_from_start: 9000)
SplitTime.create(effort_id: 6, split_id: 1, lap: 1, time_from_start: 0)
SplitTime.create(effort_id: 6, split_id: 2, lap: 1, time_from_start: 3000)
SplitTime.create(effort_id: 6, split_id: 3, lap: 1, time_from_start: 3100)
SplitTime.create(effort_id: 6, split_id: 4, lap: 1, time_from_start: 7500)

Stewardship.create(user_id: 3, organization_id: 2)
Stewardship.create(user_id: 4, organization_id: 3)

event = Event.find_by(course_id: 1)
splits = Split.where(course_id: 1)
splits.each do |split|
  event.splits << split
end