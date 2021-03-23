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

/*Le's OLAP Queries - 1-a-ii, 1-b-i, 1-d-iv, 2-b*/

/*  */

1-a-ii)
SELECT D.Day, D.Week_in_Year, D.Month, D.Year, SUM(F.resolved::INT) AS total_resolve_cases
FROM covid19_tracking_fact_table AS F, onset_date_dimension AS D
WHERE F.onset_date_surrogate_key = D.date_surrogate_key AND week_in_year = 41
GROUP BY (D.year, D.month, D.Week_in_Year, D.day)
ORDER BY D.year, D.month, D.Week_in_Year, D.day

/*  */

1-b-i) 
SELECT L.phu_name, SUM(F.resolved ::INT) AS total_cases_resolved, SUM(F.unresolved ::INT) AS total_cases_unresolved, SUM(F.fatal ::INT) AS total_cases_fatal, COUNT(P.patient_surrogate_key) AS total_cases
FROM covid19_tracking_fact_table AS F 
INNER JOIN patient_dimension P ON F.patient_surrogate_key = P.patient_surrogate_key
INNER JOIN phu_location_dimension L ON F.phu_location_surrogate_key = L.phu_location_surrogate_key
WHERE phu_name = 'York Region Public Health Services'
GROUP BY L.phu_name

/*  */

1-d-iv) 
SELECT D.full_date, M.subregion, M.retail_and_recreation, M.parks, M.transit_stations, M.workplaces, M.residential, COUNT(*) AS total_cases
FROM covid19_tracking_fact_table AS F, mobility_dimension AS M, onset_date_dimension AS D
WHERE F.mobility_surrogate_key = M.mobility_surrogate_key AND F.onset_date_surrogate_key = D.date_surrogate_key AND
M.subregion in ('Ottawa Division', 'Toronto Division')
GROUP BY (D.full_date, M.subregion, M.retail_and_recreation, M.parks, M.transit_stations, M.workplaces, M.residential)
ORDER BY D.full_date

/*  */

2-b)
SELECT D.month, D.week_in_year, SUM(F.resolved ::INT) AS total_cases_resolved, RANK() OVER (PARTITION BY D.month ORDER BY SUM(F.resolved ::INT) DESC)
FROM covid19_tracking_fact_table AS F, onset_date_dimension AS D
WHERE F.onset_date_surrogate_key = D.date_surrogate_key
GROUP BY (D.month, D.week_in_year)