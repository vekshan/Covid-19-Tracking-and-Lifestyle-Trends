/*Part 1. Standard OLAP Operations - 9 Queries*/

/*a. Drill down and roll up - 2 Queries Total*/

/*Drill Down Query (Positive Cases & October 2020)*/
SELECT D.year, D.week_in_year, D.month, D.day, SUM(F.unresolved::INT) AS total_unresolved_cases
FROM covid19_tracking_fact_table AS F, onset_date_dimension AS D
WHERE F.onset_date_surrogate_key = D.date_surrogate_key AND D.month = 10 AND D.year = 2020
GROUP BY (D.year, D.week_in_year, D.month, D.day)
ORDER BY D.year, D.week_in_year, D.month, D.day

/*Roll Up Query (Total Fatal Cases rollup to Region and City)*/
SELECT L.city, (CASE WHEN L.city = 'Ottawa' THEN 'Ottawa' ELSE 'Toronto' END) AS region, SUM(F.fatal::INT) AS total_fatal_cases
FROM covid19_tracking_fact_table AS F, phu_location_dimension AS L
WHERE F.phu_location_surrogate_key = L.phu_location_surrogate_key
GROUP BY ROLLUP(region, L.city)
ORDER BY L.city

/*b. Slice - 2 Queries*/

/*Slice Query (Total Cases in York Region Public Health Services)*/
SELECT L.phu_name, SUM(F.resolved ::INT) AS total_cases_resolved, SUM(F.unresolved ::INT) AS total_cases_unresolved, SUM(F.fatal ::INT) AS total_cases_fatal, COUNT(P.patient_surrogate_key) AS total_cases
FROM covid19_tracking_fact_table AS F 
INNER JOIN patient_dimension P ON F.patient_surrogate_key = P.patient_surrogate_key
INNER JOIN phu_location_dimension L ON F.phu_location_surrogate_key = L.phu_location_surrogate_key
WHERE phu_name = 'York Region Public Health Services'
GROUP BY L.phu_name

/**/
-- Add Here @Vekshan

/*c. Dice - 2 Queries*/

/* Dice Query (Total Unresolved Cases for Sub Region and Precipitation)*/
SELECT M.subregion, M.parks, M.transit_stations, W.precipitation, SUM(F.unresolved::INT) AS total_unresolved_cases
FROM covid19_tracking_fact_table AS F, mobility_dimension AS M, weather_dimension as W
WHERE F.mobility_surrogate_key = M.mobility_surrogate_key AND F.weather_surrogate_key = W.weather_surrogate_key 
AND M.subregion in ('Ottawa Division', 'Toronto Division') AND W.precipitation > 0
GROUP BY (M.subregion, M.parks, M.transit_stations, W.precipitation)

/**/
-- Add Here @Vekshan

/*d. Combining OLAP operations - 3 Queries*/

/*Combined OLAP Operations Query (Outcomes and Weather Conditions for Cold Days with Precipitation)*/
SELECT M.subregion, W.daily_low_temperature, W.precipitation, SUM(F.resolved::INT) AS total_resolved_cases, 
SUM(F.unresolved::INT) AS total_unresolved_cases, SUM(F.fatal::INT) AS total_fatal_cases
FROM covid19_tracking_fact_table AS F, mobility_dimension AS M, weather_dimension as W
WHERE F.mobility_surrogate_key = M.mobility_surrogate_key AND F.weather_surrogate_key = W.weather_surrogate_key
AND M.subregion in ('Ottawa Division', 'Toronto Division') AND W.daily_low_temperature <= 4 AND W.precipitation >= 0
GROUP BY (M.subregion, W.daily_low_temperature, W.precipitation)

/*Combined OLAP Operations Query (Contrast Weather Conditions, Special Measure and Total Cases)*/
SELECT M.subregion, S.title, W.daily_high_temperature, W.daily_low_temperature, W.precipitation, AVG(F.total_cases) AS average_total_cases
FROM (
 SELECT onset_date_surrogate_key, mobility_surrogate_key, weather_surrogate_key, special_measures_surrogate_key, COUNT(*) as total_cases 
 FROM covid19_tracking_fact_table 
 GROUP BY (onset_date_surrogate_key, mobility_surrogate_key, weather_surrogate_key, special_measures_surrogate_key)
) AS F, mobility_dimension AS M, weather_dimension as W, special_measures_dimension as S
WHERE F.mobility_surrogate_key = M.mobility_surrogate_key AND F.weather_surrogate_key = W.weather_surrogate_key AND F.special_measures_surrogate_key = S.special_measures_surrogate_key 
AND M.subregion in ('Ottawa Division', 'Toronto Division') AND W.daily_low_temperature >= 17 AND W.precipitation <= 2.5 AND S.title = 'Stage 3'
GROUP BY (M.subregion, S.title, W.daily_high_temperature, W.daily_low_temperature, W.precipitation)

/*Combined OLAP Operations Query (Contrasting Mobility Levels in Ottawa and Toronto)*/
SELECT D.full_date, M.subregion, M.retail_and_recreation, M.parks, M.transit_stations, M.workplaces, M.residential, COUNT(*) AS total_cases
FROM covid19_tracking_fact_table AS F, mobility_dimension AS M, onset_date_dimension AS D
WHERE F.mobility_surrogate_key = M.mobility_surrogate_key AND F.onset_date_surrogate_key = D.date_surrogate_key AND
M.subregion in ('Ottawa Division', 'Toronto Division')
GROUP BY (D.full_date, M.subregion, M.retail_and_recreation, M.parks, M.transit_stations, M.workplaces, M.residential)
ORDER BY D.full_date

/*Part 2. Explorative Operations - 3 Queries Total*/

/*a. Iceberg Query*/

/*Iceberg Query (Top-N for Total Cases on a Date)*/
SELECT D.full_date, COUNT(*) AS total_cases
FROM covid19_tracking_fact_table AS F, onset_date_dimension AS D
WHERE F.onset_date_surrogate_key = D.date_surrogate_key
GROUP BY D.full_date
ORDER BY total_cases DESC
LIMIT 5

/*b. Windowing Query*/

/*Windowing Query (?)*/
SELECT D.month, D.week_in_year, SUM(F.resolved ::INT) AS total_cases_resolved, RANK() OVER (PARTITION BY D.month ORDER BY SUM(F.resolved ::INT) DESC)
FROM covid19_tracking_fact_table AS F, onset_date_dimension AS D
WHERE F.onset_date_surrogate_key = D.date_surrogate_key
GROUP BY (D.month, D.week_in_year)

/*c. Using the Window Clause Query*/

/**/
-- Add Here @Vekshan



--



/*Vekshan's Queries*/

-- b(ii), c(i), d(ii)

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