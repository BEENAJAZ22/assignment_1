USE earthquake_db;

-- 1. Top 10 strongest earthquakes
SELECT id, place, mag, time
FROM earthquakes
ORDER BY mag DESC
LIMIT 10;

-- 2. Top 10 deepest earthquakes
SELECT id, place, depth_km, time
FROM earthquakes
ORDER BY depth_km DESC
LIMIT 10;

-- 3. Shallow earthquakes (<50 km) with mag > 7.5
SELECT id, place, mag, depth_km
FROM earthquakes
WHERE depth_km < 50 AND mag > 7.5;

-- 4. Average depth per continent
SELECT continent, AVG(depth_km) AS avg_depth
FROM earthquakes
GROUP BY continent;



-- 5. Average magnitude by magnitude type
SELECT magType, AVG(mag) AS avg_mag
FROM earthquakes
GROUP BY magType;

-- 6.Year with most earthquakes
SELECT 
    YEAR(time) AS year,
    COUNT(*) AS total_earthquakes
FROM earthquakes
GROUP BY YEAR(time)
ORDER BY total_earthquakes DESC
LIMIT 1;



-- 7. Month with highest earthquakes
SELECT MONTH(time) AS month, COUNT(*) AS quake_count
FROM earthquakes
GROUP BY month
ORDER BY quake_count DESC
LIMIT 1;


-- 8.Day of week with most earthquakes
SELECT 
    DAYNAME(time) AS day,
    COUNT(*) AS quake_count
FROM earthquakes
GROUP BY DAYNAME(time)
ORDER BY quake_count DESC;


-- 9.Earthquake count per hour
SELECT HOUR(time) AS hour, COUNT(*) AS quake_count
FROM earthquakes
GROUP BY hour
ORDER BY hour;

-- 10.Most active reporting network
SELECT net, COUNT(*) AS quake_count
FROM earthquakes
GROUP BY net
ORDER BY quake_count DESC
LIMIT 1;

-- 11. Top 5 places with highest casualties
SELECT 
    place,
    SUM(sig) AS total_casualties
FROM earthquakes
WHERE sig IS NOT NULL
GROUP BY place
ORDER BY total_casualties DESC
LIMIT 5;

-- 12.Total estimated economic loss per continent.
SELECT continent, SUM(economic_loss) AS total_loss
FROM earthquakes
GROUP BY continent;


-- 13.Average economic loss by alert level.
SELECT 
    status,
    AVG(sig) AS avg_loss
FROM earthquakes
GROUP BY status;


-- 14.Reviewed vs automatic earthquakes
SELECT status, COUNT(*) AS count
FROM earthquakes
GROUP BY status;

-- 15.Count by earthquake type (type).
SELECT type, COUNT(*) AS total_events
FROM earthquakes
GROUP BY type;

-- 16.Number of earthquakes by data type (types).
SELECT types, COUNT(*) AS count
FROM earthquakes
GROUP BY types;

-- 17.Average RMS and GAP
SELECT continent,
       AVG(rms) AS avg_rms,
       AVG(gap) AS avg_gap
FROM earthquakes
GROUP BY continent;

-- 18. Events with high station coverage (nst > threshold).
SELECT *
FROM earthquakes
WHERE nst > 50;


-- 19. Number of tsunamis triggered per year.
SELECT 
    YEAR(time) AS year,
    COUNT(*) AS tsunami_count
FROM earthquakes
WHERE tsunami = 1
GROUP BY YEAR(time)
ORDER BY year;

-- 20.Count earthquakes by alert levels (red, orange, etc.)
SELECT 
    status,
    COUNT(*) AS count
FROM earthquakes
GROUP BY status;

-- 21.Find the top 5 countries with the highest average magnitude of earthquakes in the past 10 years
SELECT 
    TRIM(SUBSTRING_INDEX(place, ',', -1)) AS country,
    AVG(mag) AS avg_magnitude
FROM earthquakes
WHERE YEAR(time) >= YEAR(CURDATE()) - 10
GROUP BY TRIM(SUBSTRING_INDEX(place, ',', -1))
ORDER BY avg_magnitude DESC
LIMIT 5;


-- 22.Places with shallow & deep quakes in same month
SELECT 
  place
FROM earthquakes
GROUP BY 
  place,
  YEAR(time),
  MONTH(time)
HAVING 
  SUM(depth_km < 70) > 0
  AND SUM(depth_km > 300) > 0;


-- 23.Year-over-year earthquake count
SELECT 
  YEAR(time) AS year,
  COUNT(*) AS quake_count
FROM earthquakes
GROUP BY YEAR(time)
ORDER BY YEAR(time);


-- 24.Most seismically active places
SELECT place, COUNT(*) AS freq, AVG(mag) AS avg_mag
FROM earthquakes
GROUP BY place
ORDER BY freq DESC, avg_mag DESC
LIMIT 3;

-- 25.Average depth near equator (±5°)
SELECT place, AVG(depth_km) AS avg_depth
FROM earthquakes
WHERE latitude BETWEEN -5 AND 5
GROUP BY place;

-- 26.Ratio of shallow to deep earthquakes
SELECT place,
SUM(CASE WHEN depth_km < 70 THEN 1 ELSE 0 END) /
SUM(CASE WHEN depth_km > 300 THEN 1 ELSE 0 END) AS ratio
FROM earthquakes
GROUP BY place;

-- 27.Avg magnitude with vs without tsunami
SELECT tsunami, AVG(mag) AS avg_mag
FROM earthquakes
GROUP BY tsunami;

-- 28. Lowest data reliability events
SELECT id, place, rms, gap
FROM earthquakes
ORDER BY rms DESC, gap DESC
LIMIT 10;

-- 29.Consecutive earthquakes within 50 Km within 1hr
SELECT 
  a.id AS eq1,
  b.id AS eq2,
  a.time AS time1,
  b.time AS time2
FROM earthquakes a
JOIN earthquakes b
  ON a.id < b.id
 AND ABS(TIMESTAMPDIFF(MINUTE, a.time, b.time)) <= 60
 AND (
   6371 * ACOS(
     COS(RADIANS(a.latitude)) * COS(RADIANS(b.latitude)) *
     COS(RADIANS(b.longitude) - RADIANS(a.longitude)) +
     SIN(RADIANS(a.latitude)) * SIN(RADIANS(b.latitude))
   )
 ) <= 50
 limit 10;

-- 30. Regions with deep-focus earthquakes (>300 km)
SELECT place, COUNT(*) AS deep_quakes
FROM earthquakes
WHERE depth_km > 300
GROUP BY place
ORDER BY deep_quakes DESC;
































