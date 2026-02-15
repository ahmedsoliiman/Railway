-- Insert dummy data for Trip ID 1 (Confirmed to exist)
-- Verify you have a Trip with ID=1 first. If not, change the trip_id.

insert into trip_departures (trip_id, departure_time, arrival_time, available_seats)
values
(1, NOW() + interval '1 day', NOW() + interval '1 day 3 hours', 50),
(1, NOW() + interval '2 days', NOW() + interval '2 days 3 hours', 60);

-- Check the data
select * from trip_departures;
