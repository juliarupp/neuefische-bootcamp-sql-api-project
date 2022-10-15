/*Select tables*/
SELECT *
FROM airports;

---

SELECT *
FROM flights_project_group5
WHERE flight_date = '2017-08-01';

---

SELECT *
FROM weather_dfw_g5 wdg;

---

SELECT *
FROM weather_iah_g5;

---
SELECT *
FROM weather_all_g5 wag;

SELECT *
FROM faw_origin_g5;

---

SELECT *
FROM faw_all_g5 fag;



/* get information from our flights table with 5 airports*/
SELECT COUNT(*)
FROM flights_project_group5
WHERE origin = 'JFK';
--77508 rows
--11131 IAH
--15977 DFW
--3907 MSY
--296 BTR
--8477 JFK

---

SELECT COUNT(DISTINCT dest)
FROM flights_project_group5;
--145 distinct airports

---

SELECT *
FROM flights_project_group5 fpj 
WHERE origin = 'IAH' AND cancelled = 1;



/* show our 5 selected airports from airports table*/
SELECT lat
	   , lon
	   , name
	   , faa
	   , city
FROM airports a 
WHERE faa IN ('DFW','IAH','MSY', 'BTR', 'JFK');



/* add column with faa codes to weather table*/
ALTER TABLE weather_dfw_g5
ADD COLUMN IF NOT EXISTS faa_dfw VARCHAR;

UPDATE weather_dfw_g5 
SET faa_dfw = 'DFW';

---

ALTER TABLE weather_jfk_g5
ADD COLUMN IF NOT EXISTS faa_jfk VARCHAR;

UPDATE weather_jfk_g5 
SET faa_jfk = 'JFK';



/* delete columns that are not needed*/
ALTER TABLE weather_dfw_g5
DROP COLUMN IF EXISTS tmin;

ALTER TABLE weather_dfw_g5
DROP COLUMN IF EXISTS tmax;

ALTER TABLE weather_dfw_g5
DROP COLUMN IF EXISTS snow;

ALTER TABLE weather_dfw_g5
DROP COLUMN IF EXISTS wdir;

ALTER TABLE weather_dfw_g5
DROP COLUMN IF EXISTS wpgt;

ALTER TABLE weather_dfw_g5
DROP COLUMN IF EXISTS pres;

ALTER TABLE weather_dfw_g5
DROP COLUMN IF EXISTS tsun;





/* change column names*/
ALTER TABLE weather_dfw_g5 
RENAME COLUMN tavg TO avg_temp;

ALTER TABLE weather_dfw_g5
RENAME COLUMN prcp TO rain;

ALTER TABLE weather_dfw_g5
RENAME COLUMN wspd TO wind_speed;

---

ALTER TABLE weather_jfk_g5 
RENAME COLUMN tavg TO avg_temp;

ALTER TABLE weather_jfk_g5
RENAME COLUMN prcp TO rain;

ALTER TABLE weather_jfk_g5
RENAME COLUMN wspd TO wind_speed;



/* drop rows where weather is null*/
DELETE FROM faw_origin_g5
WHERE date IS NULL
AND avg_temp IS NULL
AND rain IS NULL
AND wind_speed IS NULL
AND w_faa IS NULL;



/* join weather tables by union*/
CREATE weather_all_g5 AS
SELECT *
FROM weather_dfw_g5
UNION
SELECT *
FROM weather_iah_g5
UNION
SELECT *
FROM weather_msy_g5
UNION
SELECT
FROM weather_jfk_g5 wjg;



/* join airports, our flights table and all the weather tables*/
CREATE TABLE faw_origin_g5 AS
SELECT *
FROM flights_project_group5 fpg
LEFT JOIN airports a
	ON fpg.origin = a.faa
LEFT JOIN weather_all_g5 wa
	ON fpg.flight_date = wa.date AND fpg.origin = wa.w_faa;


CREATE TABLE faw_dest_g5 AS
SELECT *
FROM flights_project_group5 fpg
LEFT JOIN airports a2 
	ON fpg.dest = a2.faa
LEFT JOIN weather_all_g5 wa2
	ON fpg.flight_date = wa2.date AND fpg.dest = wa2.w_faa;



/* counting how many flights per day got cancelled
 * -> more efficient in python*/
SELECT COUNT(*)
FROM faw_origin_g5 fog  
WHERE cancelled = 1 AND origin = 'DFW' AND flight_date = '2017-08-01';



/* Correlation*/
SELECT *
FROM faw_origin_g5 fog;

SELECT CORR(cancelled, wind_speed)
FROM faw_origin_g5 fog
WHERE origin = 'IAH';

SELECT CORR(cancelled, wind_speed)
FROM faw_dest_g5 fog
WHERE origin = 'IAH';




SELECT CORR(total_cancel_iah, wind_speed)     
FROM(SELECT SUM(cancelled) AS total_cancel_iah,
      flight_date,
      wind_speed
FROM faw_origin_g5 fog  
WHERE w_faa = 'IAH'
GROUP BY flight_date, wind_speed)fog2;
		
--0.780681
	
	
	
	
	
	
	
	
	