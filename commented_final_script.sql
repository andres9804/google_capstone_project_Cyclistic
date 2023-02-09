/*

  SQL script used to complete the Google Data Analytics
  Capstone Project Case Study 1: How does a bike-share navigate speedy success?

  Data was cleaned and analyzed using BigQuery free version
  so I wasn't able to use DML functions to clean my data.

  It uses 2022 data from Divvy Bikes (https://divvy-tripdata.s3.amazonaws.com/index.html)

  Steps followed before this point:
  1.Download the data.
  2.Split the 100mb+ files into smaller files using Excel
    due to BigQuerys restrictions.
  3.Upload all files into individual tables
  4.Combine all tables into a single table.
  5.Analyze data for inconsistencies and clean it.
  6.Save all results into a new table
  7.Create queries for visualizations and analysis.

  This script starts at step 4.

*/
  


--STEP 4: Combine all monthly tables into a single year table----------------------------------------
SELECT *
FROM `coursera-359716.biketrips.trips_202201`

UNION ALL

SELECT *
FROM `coursera-359716.biketrips.trips_202202`

UNION ALL

SELECT *
FROM `coursera-359716.biketrips.trips_202203`

UNION ALL

SELECT *
FROM `coursera-359716.biketrips.trips_202204`

UNION ALL

SELECT *
FROM `coursera-359716.biketrips.trips_202205`

UNION ALL

SELECT *
FROM `coursera-359716.biketrips.trips_202205_2`

UNION ALL

SELECT *
FROM `coursera-359716.biketrips.trips_202206`

UNION ALL

SELECT *
FROM `coursera-359716.biketrips.trips_202206_2`

UNION ALL

SELECT *
FROM `coursera-359716.biketrips.trips_202207`

UNION ALL

SELECT *
FROM `coursera-359716.biketrips.trips_202207_2`

UNION ALL

SELECT *
FROM `coursera-359716.biketrips.trips_202208`

UNION ALL

SELECT *
FROM `coursera-359716.biketrips.trips_202208_2`

UNION ALL

SELECT *
FROM `coursera-359716.biketrips.trips_202209`

UNION ALL

SELECT *
FROM `coursera-359716.biketrips.trips_202209_2`

UNION ALL

SELECT *
FROM `coursera-359716.biketrips.trips_202210`

UNION ALL

SELECT *
FROM `coursera-359716.biketrips.trips_202210_2`

UNION ALL

SELECT *
FROM `coursera-359716.biketrips.trips_202211`

UNION ALL

SELECT *
FROM `coursera-359716.biketrips.trips_202212`;

-- Resuting query was saved as a new table ('trips_2022')

/*
  To clean and analyze the trip durations I decided to create a temp table using the WITH clause
  and then store the temp table as a new table (trips2022_length) that now contains the trip lengths
*/

--Creating temp table to add ride lengths and then saving it as a new table
WITH trips2022_length AS
(
  SELECT  
    *,
    TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS ride_length_min
  FROM
    `coursera-359716.biketrips.trips_2022`
)
SELECT
  *
FROM
  trips2022_length;


--Step 5: Analyze data for inconsistencies and clean it-----------------------------------------------------
--Looking for possible duplicated trips on the ride_id
SELECT
  ride_id,
  COUNT(1)
FROM
`coursera-359716.biketrips.trips2022_length`
GROUP BY
  ride_id
HAVING
  COUNT(1)>1;

-- Looking for null values in ride_id
SELECT
  ride_id
FROM
  `coursera-359716.biketrips.trips2022_length`
WHERE
  ride_id IS NULL;


--Checking for misspells and on rideable_type
SELECT DISTINCT
  rideable_type
FROM
  `coursera-359716.biketrips.trips2022_length`
GROUP BY
  rideable_type;

--Checking for nulls on rideable_type
SELECT
  rideable_type
FROM
  `coursera-359716.biketrips.trips2022_length`
WHERE
  rideable_type IS NULL;

--checking started_at and ended_at columns
/* 
  This query for the ride_length_min column will detect
  'started_at > ended_at' (negative values) or when 'started_at = ended_at (0 values)'
*/
SELECT
  started_at,
  ended_at,
  ride_length_min
FROM
  `coursera-359716.biketrips.trips2022_length`
WHERE
  ride_length_min <= 0;

-- Checking for nulls
SELECT
  *
FROM
  `coursera-359716.biketrips.trips2022_length`
WHERE
  started_at IS NULL OR ended_at IS NULL;

--Checking station names and ID's
--Checking start station
SELECT
  start_station_name,
  start_station_id,
  COUNT(1)
FROM
  `coursera-359716.biketrips.trips2022_length`
GROUP BY
  start_station_name,
  start_station_id
ORDER BY
  COUNT(1) DESC;

--Checking end station
SELECT
  end_station_name,
  end_station_id,
  COUNT(1)
FROM
  `coursera-359716.biketrips.trips2022_length`
GROUP BY
  end_station_name,
  end_station_id
ORDER BY
  COUNT(1) DESC;

/*
  I've noticed there are tons of null values in the station names
  that could be filled with the latitude and longitude data, but
  since there's no further instruction on that and some lat and
  lng data can be misinterpreted since there are different stations
  really close to each other, i'll delete those null values.
*/
SELECT
  start_station_name,
  end_station_name
FROM
  `coursera-359716.biketrips.trips2022_length`
WHERE
  start_station_name IS NULL OR end_station_name IS NULL
GROUP BY
  start_station_name,
  end_station_name;
--Checking the lat and lng columns, I'll check it with the MAX and MIN in each one
SELECT
  MIN(start_lat) AS min_slat,
  MAX(start_lat) AS max_slat,
  MIN(start_lng) AS min_slng,
  MAX(start_lng) AS max_slng,
  MIN(end_lat) AS min_elat,
  MAX(end_lat) AS max_elat,
  MIN(end_lng) AS min_elng,
  MAX(end_lng) AS max_elng
FROM
  `coursera-359716.biketrips.trips2022_length`
WHERE
  end_lat > 0 OR end_lng < 0;

--Check some rows that had end_lat and lng = 0
SELECT
  *
FROM 
  `coursera-359716.biketrips.trips2022_length`
WHERE
  end_lng = 0;

--Check for nulls
SELECT
  start_lat,
  start_lng,
  end_lat,
  end_lng,
  COUNT(1)
FROM
  `coursera-359716.biketrips.trips2022_length`
WHERE
  start_lat IS NULL OR
  start_lng IS NULL OR
  end_lat IS NULL OR
  end_lng IS NULL
GROUP BY
  start_lat,
  start_lng,
  end_lat,
  end_lng;

  SELECT *
  FROM `coursera-359716.biketrips.trips2022_length`
  WHERE
    end_lng IS NULL;

-- Checking member_casual
SELECT DISTINCT
  member_casual
FROM
  `coursera-359716.biketrips.trips2022_length`;

--check for nulls in member_casual
SELECT
  member_casual
FROM
  `coursera-359716.biketrips.trips2022_length`
WHERE
  member_casual IS NULL;

--Step 6: Final query to save it as a new table--------------------------------------------
--Final query, also added trip weekday column
WITH final_2022trips AS
(
SELECT
  *,
  FORMAT_DATE('%A', started_at) AS started_at_weekday
FROM
  `coursera-359716.biketrips.trips2022_length`
WHERE
  (start_station_name IS NOT NULL AND
  end_station_name IS NOT NULL) AND
  (ride_length_min > 0) AND
  (end_lat > 0) AND
  (end_lng < 0) AND
  (end_lng IS NOT NULL)
)
SELECT
  *
FROM
  final_2022trips
WHERE
  ride_id IN 
  (
    SELECT
      ride_id
    FROM
      final_2022trips
    GROUP BY
      ride_id
    HAVING
      COUNT(ride_id)=1
  );

## query output saved as new table ('final_2022trips'), 

--Step 7: Creating queries for visualizations and analysis------------------------------------------------------------
--Queries that I used to create my vizes in Tableau

--Trips by weekday grouped by member_casual
SELECT
  started_at_weekday,
  member_casual,
  COUNT(ride_id) AS trip_count
FROM
  `coursera-359716.biketrips.final_2022trips`
GROUP BY
  started_at_weekday,
  member_casual;

--trips by month of the year grouped by member_casual
WITH months AS
(
  SELECT
    *,
    FORMAT_DATE('%B', started_at) AS trip_month
  FROM
    `coursera-359716.biketrips.final_2022trips`
)
SELECT
  months.trip_month,
  member_casual,
  COUNT(ride_id)
FROM
  months
GROUP BY
  months.trip_month,
  member_casual;

/*----------Notes from viz
  May is when both member_casual trips are almost the same
  June too
  July too
  trend drops at august
  continues at september (kind of)
  Theres a big difference in December 30-101
*/

--AVG trip length by year, month and weekday
-- By year
SELECT
  member_casual,
  CAST(ROUND(AVG(ride_length_min))AS INT64) AS ride_length
FROM
  `coursera-359716.biketrips.final_2022trips`
GROUP BY
  member_casual;

--By month
WITH months AS
(
  SELECT
    *,
    FORMAT_DATE('%B', started_at) AS trip_month
  FROM
    `coursera-359716.biketrips.final_2022trips`
)
SELECT
  months.trip_month,
  member_casual,
  CAST(ROUND(AVG(ride_length_min)) AS INT64) AS average_ride_length
FROM
  months
GROUP BY
  member_casual,
  months.trip_month
ORDER BY
  months.trip_month ASC;

--By weekday
SELECT
  started_at_weekday,
  member_casual,
  ROUND(AVG(ride_length_min)) AS average_ride_length
FROM
  `coursera-359716.biketrips.final_2022trips`
GROUP BY
  member_casual,
  started_at_weekday
ORDER BY
  started_at_weekday;

--Average trip length by hour of the day
WITH trips_hour AS
(
  SELECT
    *,
    CAST(started_at AS STRING FORMAT'HH12 AM' ) AS trip_hour
  FROM
    `coursera-359716.biketrips.final_2022trips`  
)
SELECT
  trips_hour.trip_hour,
  member_casual,
  CAST(ROUND(AVG(ride_length_min)) AS INT64) AS average_ride_length
FROM
  trips_hour
GROUP BY
  trips_hour.trip_hour,
  member_casual;

--Hour of the day that trips are started by member_casual
WITH trips_hour AS
(
  SELECT
    *,
    CAST(started_at AS STRING FORMAT'HH12 AM' ) AS trip_hour
  FROM
    `coursera-359716.biketrips.final_2022trips`  
)
SELECT
  trips_hour.trip_hour,
  member_casual,
  COUNT(ride_id) AS trip_count
FROM
  trips_hour
GROUP BY
  member_casual,
  trips_hour.trip_hour
ORDER BY
  trips_hour.trip_hour;
## This may be done with the trendy months also form the "trips by month of the year grouped by member_casual" query.

--Trips into day of month trends by casual_member
WITH months AS
(
  SELECT
    *,
    FORMAT_DATE('%B', started_at) AS trip_month,
    FORMAT_DATE('%d',started_at) AS day_of_month
  FROM
    `coursera-359716.biketrips.final_2022trips`
)
SELECT
  months.day_of_month,
  COUNT(ride_id)
FROM
  months
WHERE
  months.trip_month = 'January'--MONTH NAME HERE
GROUP BY
  months.day_of_month
ORDER BY
  months.day_of_month;

--Rides by type of bike into member_casual
SELECT
  rideable_type,
  member_casual,
  COUNT(ride_id)
FROM
  `coursera-359716.biketrips.final_2022trips`
GROUP BY
  member_casual,
  rideable_type
ORDER BY
  member_casual;

--Trips longer than 60 minutes by member type
SELECT
  member_casual,
  COUNT(ride_length_min) AS longer_than_hour_trips
FROM
  `coursera-359716.biketrips.final_2022trips`
WHERE
  ride_length_min > 60
GROUP BY
  member_casual;

--Trips longer than 60 minutes by member type
SELECT
  member_casual,
  COUNT(ride_length_min) AS longer_than_hour_trips
FROM
  `coursera-359716.biketrips.final_2022trips`
WHERE
  ride_length_min > 720
GROUP BY
  member_casual;

--Average length of trips longer than 1 hour
SELECT
  member_casual,
  CAST(ROUND(AVG(ride_length_min)) AS INT64) AS average_ride_length
FROM
  `coursera-359716.biketrips.final_2022trips`
WHERE
  ride_length_min > 60
GROUP BY
  member_casual;

--Most used start stations by member type
SELECT
  DISTINCT start_station_name,
  start_lat,
  start_lng,
  member_casual,
  COUNT(start_station_name) AS num_trips_started
FROM
  `coursera-359716.biketrips.final_2022trips`
GROUP BY
  start_station_name,
  start_lat,
  start_lng,
  member_casual
ORDER BY
  num_trips_started DESC
LIMIT 1000;

--Most used start stations
SELECT
  DISTINCT start_station_name,
  start_lat,
  start_lng,
  COUNT(start_station_name) AS num_trips_started
FROM
  `coursera-359716.biketrips.final_2022trips`
GROUP BY
  start_station_name,
  start_lat,
  start_lng
ORDER BY
  num_trips_started DESC
LIMIT 10;

-- Most used end stations by member type
SELECT
  DISTINCT end_station_name,
  end_lat,
  end_lng,
  member_casual,
  COUNT(end_station_name) AS num_trips_ended
FROM
  `coursera-359716.biketrips.final_2022trips`
GROUP BY
  end_station_name,
  end_lat,
  end_lng,
  member_casual
ORDER BY
  num_trips_ended DESC
LIMIT 1000;
