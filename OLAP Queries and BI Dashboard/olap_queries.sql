-- b(ii), c(i), d(ii)

/*  */

SELECT 
l.phu_name,
SUM(f.resolved ::INT) AS total_cases_resolved,
SUM(f.unresolved ::INT) AS total_cases_unresolved,
SUM(f.fatal ::INT) AS total_cases_fatal,
COUNT(p.patient_surrogate_key) AS total_cases
FROM 
covid19_tracking_fact_table f 
INNER JOIN 
patient_dimension p
ON f.patient_surrogate_key = p.patient_surrogate_key
INNER JOIN 
special_measures_dimension s
ON 
f.special_measures_surrogate_key = s.special_measures_surrogate_key
INNER JOIN 
phu_location_dimension l
ON
f.phu_location_surrogate_key = l.phu_location_surrogate_key
WHERE
s.title = 'Stage 3 Modified'
GROUP BY
l.phu_name

/*  */

SELECT
l.phu_name,
COUNT(p.patient_surrogate_key) AS total_cases_fatal
FROM 
covid19_tracking_fact_table f 
INNER JOIN 
patient_dimension p
ON f.patient_surrogate_key = p.patient_surrogate_key
INNER JOIN 
phu_location_dimension l
ON
f.phu_location_surrogate_key = l.phu_location_surrogate_key
INNER JOIN 
onset_date_dimension d
ON
f.onset_date_surrogate_key = d.date_surrogate_key
WHERE
f.fatal is TRUE
AND 
l.city IN ('Mississauga', 'Ottawa')
AND
d.month IN (7,8)
GROUP BY
l.phu_name

/*  */

SELECT
s.title AS special_measure, 
s.description,
s.start_date,
s.end_date,
SUM(f.resolved ::INT) AS total_cases_resolved,
SUM(f.unresolved ::INT) AS total_cases_unresolved,
SUM(f.fatal ::INT) AS total_cases_fatal,
COUNT(*) AS total_cases
FROM 
covid19_tracking_fact_table f,
special_measures_dimension s
WHERE
f.special_measures_surrogate_key = s.special_measures_surrogate_key 
GROUP BY s.special_measures_surrogate_key

/*  */

SELECT
d.full_date,
l.city,
TO_CHAR(TO_DATE(d.month::text, 'MM'), 'Month') AS onset_month,
f.number_resolved,
AVG(f.number_resolved) OVER W AS moving_avg_resolved
FROM 
(SELECT onset_date_surrogate_key, phu_location_surrogate_key, SUM(resolved::INT) as number_resolved FROM covid19_tracking_fact_table 
GROUP BY (onset_date_surrogate_key, phu_location_surrogate_key, resolved)) AS f,
phu_location_dimension l,
onset_date_dimension d
WHERE
f.phu_location_surrogate_key = l.phu_location_surrogate_key
AND
f.onset_date_surrogate_key = d.date_surrogate_key
AND l.city = 'Ottawa'
GROUP BY d.month, l.city, f.number_resolved, d.full_date
WINDOW W AS 
(PARTITION BY l.city
ORDER BY d.full_date
RANGE BETWEEN  '15 days' PRECEDING
AND '15 days' FOLLOWING)

/*Tableau */

/*  */

SELECT
s.title AS special_measure, 
s.description,
s.start_date,
s.end_date,
SUM(f.resolved ::INT) AS total_cases_resolved,
SUM(f.unresolved ::INT) AS total_cases_unresolved,
SUM(f.fatal ::INT) AS total_cases_fatal,
COUNT(*) AS total_cases
FROM 
covid19_tracking_fact_table f,
special_measures_dimension s
WHERE
f.special_measures_surrogate_key = s.special_measures_surrogate_key 
GROUP BY s.special_measures_surrogate_key

/*  */

SELECT
s.title AS special_measure, 
s.description,
s.start_date,
s.end_date,
SUM(f.resolved ::INT) AS total_cases_resolved,
SUM(f.unresolved ::INT) AS total_cases_unresolved,
SUM(f.fatal ::INT) AS total_cases_fatal,
COUNT(*) AS total_cases
FROM 
covid19_tracking_fact_table f,
special_measures_dimension s
WHERE
f.special_measures_surrogate_key = s.special_measures_surrogate_key 
GROUP BY s.special_measures_surrogate_key

/*  */

SELECT
d.full_date,
TO_CHAR(TO_DATE(d.month::text, 'MM'), 'Month') AS onset_month,
f.total_cases,
AVG(f.total_cases) OVER W AS moving_average
FROM 
(
 SELECT onset_date_surrogate_key, phu_location_surrogate_key, COUNT(*) as total_cases 
 FROM covid19_tracking_fact_table 
 GROUP BY (onset_date_surrogate_key, phu_location_surrogate_key)
) AS f,
phu_location_dimension l,
onset_date_dimension d
WHERE
f.phu_location_surrogate_key = l.phu_location_surrogate_key
AND
f.onset_date_surrogate_key = d.date_surrogate_key
GROUP BY d.month, f.total_cases, d.full_date
WINDOW W AS 
(ORDER BY d.full_date
RANGE BETWEEN  '7 days' PRECEDING
AND '7 days' FOLLOWING)

/*  */

SELECT
l.phu_name,
d.season,
d.full_date,
p.acquisition_group,
COUNT(p.patient_surrogate_key) AS total_cases
FROM 
covid19_tracking_fact_table f 
INNER JOIN 
patient_dimension p
ON f.patient_surrogate_key = p.patient_surrogate_key
INNER JOIN 
phu_location_dimension l
ON
f.phu_location_surrogate_key = l.phu_location_surrogate_key
INNER JOIN 
onset_date_dimension d
ON
f.onset_date_surrogate_key = d.date_surrogate_key
WHERE
p.acquisition_group in ('CS', 'CC')
GROUP BY
l.phu_name, d.full_date, d.season, p.acquisition_group
ORDER BY d.full_date

/* To be considered */

SELECT
l.phu_name,
d.full_date,
f.total_cases,
f.acquisition_group,
AVG(f.total_cases) OVER W AS moving_average
FROM 
(
	SELECT onset_date_surrogate_key, phu_location_surrogate_key, COUNT(*) as total_cases, acquisition_group 
	FROM covid19_tracking_fact_table 
	INNER JOIN patient_dimension 
	ON covid19_tracking_fact_table.patient_surrogate_key = patient_dimension.patient_surrogate_key
	GROUP BY (acquisition_group, onset_date_surrogate_key, phu_location_surrogate_key)
) AS f
INNER JOIN 
phu_location_dimension l
ON
f.phu_location_surrogate_key = l.phu_location_surrogate_key
INNER JOIN 
onset_date_dimension d
ON
f.onset_date_surrogate_key = d.date_surrogate_key
GROUP BY
l.phu_name, d.full_date, f.total_cases, f.acquisition_group
WINDOW W AS 
(ORDER BY d.full_date
RANGE BETWEEN  '7 days' PRECEDING
AND '7 days' FOLLOWING)

/* Sukhu's Queries */

/*Drill Down Query (October 2020)*/
SELECT D.year, D.week_in_year, D.month, D.day, SUM(F.unresolved::INT) AS total_unresolved_cases
FROM covid19_tracking_fact_table AS F, onset_date_dimension AS D
WHERE F.onset_date_surrogate_key = D.date_surrogate_key AND D.month = 10 AND D.year = 2020
GROUP BY (D.year, D.week_in_year, D.month, D.day)
ORDER BY D.year, D.week_in_year, D.month, D.day

/*Drill Down Query (October 2020)*/
SELECT D.full_date, COALESCE(sum(CASE WHEN F.unresolved THEN 1 ELSE 0 END), 0) as total_unresolved_cases
FROM covid19_tracking_fact_table AS F, reported_date_dimension AS D
WHERE F.reported_date_surrogate_key = D.date_surrogate_key AND (D.full_date >= '2020-10-01' AND D.full_date <= '2020-10-31')
GROUP BY (D.full_date)
ORDER BY D.full_date

/*Roll Up Query (Total Fatal Cases rollup to City)*/
SELECT L.city, SUM(F.fatal::INT) AS total_fatal_cases
FROM covid19_tracking_fact_table AS F, phu_location_dimension AS L
WHERE F.phu_location_surrogate_key = L.phu_location_surrogate_key
GROUP BY ROLLUP(L.city)
ORDER BY L.city

/*Roll Up Query (Total Fatal Cases rollup to Region and City)*/
SELECT L.city, (CASE WHEN L.city = 'Ottawa' THEN 'Ottawa' ELSE 'Toronto' END) AS region, SUM(F.fatal::INT) AS total_fatal_cases
FROM covid19_tracking_fact_table AS F, phu_location_dimension AS L
WHERE F.phu_location_surrogate_key = L.phu_location_surrogate_key
GROUP BY ROLLUP(region, L.city)
ORDER BY L.city

/*Roll Up Query (Total Fatal Cases rollup to Age Group, Gender, Region and City)*/
SELECT L.city, I.age_group, I.gender, (CASE WHEN L.city = 'Ottawa' THEN 'Ottawa' ELSE 'Toronto' END) AS region, SUM(F.fatal::INT) AS total_fatal_cases
FROM covid19_tracking_fact_table AS F, phu_location_dimension AS L, patient_dimension as I
WHERE F.phu_location_surrogate_key = L.phu_location_surrogate_key AND F.patient_surrogate_key = I.patient_surrogate_key
GROUP BY I.age_group, I.gender, ROLLUP(region, L.city)
ORDER BY L.city

/*Dice Query (Total Fatal Cases for Sub Region and Precipitation)*/
SELECT M.subregion, M.parks, M.transit_stations, W.precipitation, SUM(F.fatal::INT) AS total_fatal_cases
FROM covid19_tracking_fact_table AS F, mobility_dimension AS M, weather_dimension as W
WHERE F.mobility_surrogate_key = M.mobility_surrogate_key AND F.weather_surrogate_key = W.weather_surrogate_key 
AND M.subregion in ('Ottawa Division', 'Toronto Division') AND W.precipitation > 0
GROUP BY (M.subregion, M.parks, M.transit_stations, W.precipitation)

/* Dice Query (Total Unresolved Cases for Sub Region and Precipitation)*/
SELECT M.subregion, M.parks, M.transit_stations, W.precipitation, SUM(F.unresolved::INT) AS total_unresolved_cases
FROM covid19_tracking_fact_table AS F, mobility_dimension AS M, weather_dimension as W
WHERE F.mobility_surrogate_key = M.mobility_surrogate_key AND F.weather_surrogate_key = W.weather_surrogate_key 
AND M.subregion in ('Ottawa Division', 'Toronto Division') AND W.precipitation > 0
GROUP BY (M.subregion, M.parks, M.transit_stations, W.precipitation)

/*Dice Query (Total Cases for Sub Region and Sunday)*/
SELECT M.subregion, M.parks, M.transit_stations, W.daily_high_temperature, COUNT(*) AS total_cases
FROM covid19_tracking_fact_table AS F, mobility_dimension AS M, weather_dimension as W
WHERE F.mobility_surrogate_key = M.mobility_surrogate_key AND F.weather_surrogate_key = W.weather_surrogate_key 
AND M.subregion in ('Ottawa Division', 'Toronto Division') AND W.daily_low_temperature >= 17
GROUP BY (M.subregion, M.parks, M.transit_stations, W.daily_high_temperature)

/*Combined OLAP Operations Query (Outcomes and Weather Conditions for Cold days with Precipitation)*/
SELECT M.subregion, W.daily_low_temperature, W.precipitation, SUM(F.resolved::INT) AS total_resolved_cases, 
SUM(F.unresolved::INT) AS total_unresolved_cases, SUM(F.fatal::INT) AS total_fatal_cases
FROM covid19_tracking_fact_table AS F, mobility_dimension AS M, weather_dimension as W
WHERE F.mobility_surrogate_key = M.mobility_surrogate_key AND F.weather_surrogate_key = W.weather_surrogate_key
AND M.subregion in ('Ottawa Division', 'Toronto Division') AND W.daily_low_temperature <= 4 AND W.precipitation >= 0
GROUP BY (M.subregion, W.daily_low_temperature, W.precipitation)

/*Combined OLAP Operations Query (Mobility Levels Contrast Between Ottawa and Toronto)*/
SELECT D.full_date, M.subregion, M.retail_and_recreation, M.parks, M.transit_stations, M.workplaces, M.residential, COUNT(*) AS total_cases
FROM covid19_tracking_fact_table AS F, mobility_dimension AS M, onset_date_dimension AS D
WHERE F.mobility_surrogate_key = M.mobility_surrogate_key AND F.onset_date_surrogate_key = D.date_surrogate_key AND
M.subregion in ('Ottawa Division', 'Toronto Division')
GROUP BY (D.full_date, M.subregion, M.retail_and_recreation, M.parks, M.transit_stations, M.workplaces, M.residential)
ORDER BY D.full_date

/*Combined OLAP Operations Query (Contrast Weather Conditions and Total Cases)*/
SELECT M.subregion, S.title, W.daily_high_temperature, W.daily_low_temperature, W.precipitation, AVG(F.total_cases) AS average_total_cases
FROM (
 SELECT onset_date_surrogate_key, mobility_surrogate_key, weather_surrogate_key, special_measures_surrogate_key, COUNT(*) as total_cases 
 FROM covid19_tracking_fact_table 
 GROUP BY (onset_date_surrogate_key, mobility_surrogate_key, weather_surrogate_key, special_measures_surrogate_key)
) AS F, mobility_dimension AS M, weather_dimension as W, special_measures_dimension as S
WHERE F.mobility_surrogate_key = M.mobility_surrogate_key AND F.weather_surrogate_key = W.weather_surrogate_key AND F.special_measures_surrogate_key = S.special_measures_surrogate_key 
AND M.subregion in ('Ottawa Division', 'Toronto Division') AND W.daily_low_temperature >= 17 AND W.precipitation <= 2.5 AND S.title = 'Stage 3'
GROUP BY (M.subregion, S.title, W.daily_high_temperature, W.daily_low_temperature, W.precipitation)

/*Iceberg Query (Top-N for Total Resolved Cases on a Date)*/
SELECT D.full_date, SUM(F.resolved::INT) AS total_resolved_cases
FROM covid19_tracking_fact_table AS F, date_dimension AS D
WHERE F.reported_date_surrogate_key = D.date_surrogate_key
GROUP BY D.full_date
ORDER BY total_resolved_cases DESC
LIMIT 5

/*Iceberg Query (Top-N for Total Fatal Cases on a Date)*/
SELECT D.full_date, SUM(F.fatal::INT) AS total_fatal_cases
FROM covid19_tracking_fact_table AS F, date_dimension AS D
WHERE F.reported_date_surrogate_key = D.date_surrogate_key
GROUP BY D.full_date
ORDER BY total_fatal_cases DESC
LIMIT 5

/*Iceberg Query (Top-N for Total Cases on a Date)*/
SELECT D.full_date, COUNT(*) AS total_cases
FROM covid19_tracking_fact_table AS F, date_dimension AS D
WHERE F.reported_date_surrogate_key = D.date_surrogate_key
GROUP BY D.full_date
ORDER BY total_cases DESC
LIMIT 5

/*Iceberg Query (Bottom-N for Total Resolved Cases on a Date)*/
SELECT D.full_date, SUM(F.resolved::INT) AS total_resolved_cases
FROM covid19_tracking_fact_table AS F, date_dimension AS D
WHERE F.reported_date_surrogate_key = D.date_surrogate_key
GROUP BY D.full_date
ORDER BY total_resolved_cases ASC
LIMIT 5

/*Iceberg Query (Bottom-N for Total Resolved Cases on a Date)*/
SELECT D.full_date, SUM(F.fatal::INT) AS total_fatal_cases
FROM covid19_tracking_fact_table AS F, date_dimension AS D
WHERE F.reported_date_surrogate_key = D.date_surrogate_key
GROUP BY D.full_date
ORDER BY total_fatal_cases ASC
LIMIT 5