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