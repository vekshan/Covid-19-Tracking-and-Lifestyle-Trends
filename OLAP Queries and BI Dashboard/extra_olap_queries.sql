/*Extra Queries made for Parts 1, 2 & 3*/

/*Drill Down Query (Positive Cases & October 2020)*/
SELECT D.full_date, COALESCE(sum(CASE WHEN F.unresolved THEN 1 ELSE 0 END), 0) as total_unresolved_cases
FROM covid19_tracking_fact_table AS F, reported_date_dimension AS D
WHERE F.reported_date_surrogate_key = D.date_surrogate_key AND (D.full_date >= '2020-10-01' AND D.full_date <= '2020-10-31')
GROUP BY (D.full_date)
ORDER BY D.full_date

/*Drill Down Query (Resolved Cases & Week 41 in 2020)*/
SELECT D.Day, D.Week_in_Year, D.Month, D.Year, SUM(F.resolved::INT) AS total_resolve_cases
FROM covid19_tracking_fact_table AS F, onset_date_dimension AS D
WHERE F.onset_date_surrogate_key = D.date_surrogate_key AND week_in_year = 41
GROUP BY (D.year, D.month, D.Week_in_Year, D.day)
ORDER BY D.year, D.month, D.Week_in_Year, D.day

/*Roll Up Query (Total Fatal Cases rollup to City)*/
SELECT L.city, SUM(F.fatal::INT) AS total_fatal_cases
FROM covid19_tracking_fact_table AS F, phu_location_dimension AS L
WHERE F.phu_location_surrogate_key = L.phu_location_surrogate_key
GROUP BY ROLLUP(L.city)
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

/*Dice Query (Total Cases for Sub Region and Sunny Days)*/
SELECT M.subregion, M.parks, M.transit_stations, W.daily_high_temperature, COUNT(*) AS total_cases
FROM covid19_tracking_fact_table AS F, mobility_dimension AS M, weather_dimension as W
WHERE F.mobility_surrogate_key = M.mobility_surrogate_key AND F.weather_surrogate_key = W.weather_surrogate_key 
AND M.subregion in ('Ottawa Division', 'Toronto Division') AND W.daily_low_temperature >= 17
GROUP BY (M.subregion, M.parks, M.transit_stations, W.daily_high_temperature)

/*Combined OLAP Operations Query (Mobility Levels Contrast Between Ottawa and Toronto)*/
SELECT D.full_date, M.subregion, M.retail_and_recreation, M.parks, M.transit_stations, M.workplaces, M.residential, COUNT(*) AS total_cases
FROM covid19_tracking_fact_table AS F, mobility_dimension AS M, onset_date_dimension AS D
WHERE F.mobility_surrogate_key = M.mobility_surrogate_key AND F.onset_date_surrogate_key = D.date_surrogate_key AND
M.subregion in ('Ottawa Division', 'Toronto Division')
GROUP BY (D.full_date, M.subregion, M.retail_and_recreation, M.parks, M.transit_stations, M.workplaces, M.residential)
ORDER BY D.full_date

/*Iceberg Query (Top-N for Total Resolved Cases on a Date)*/
SELECT D.full_date, SUM(F.resolved::INT) AS total_resolved_cases
FROM covid19_tracking_fact_table AS F, onset_date_dimension AS D
WHERE F.onset_date_surrogate_key = D.date_surrogate_key
GROUP BY D.full_date
ORDER BY total_resolved_cases DESC
LIMIT 5

/*Iceberg Query (Top-N for Total Fatal Cases on a Date)*/
SELECT D.full_date, SUM(F.fatal::INT) AS total_fatal_cases
FROM covid19_tracking_fact_table AS F, onset_date_dimension AS D
WHERE F.onset_date_surrogate_key = D.date_surrogate_key
GROUP BY D.full_date
ORDER BY total_fatal_cases DESC
LIMIT 5

/*Iceberg Query (Bottom-N for Total Resolved Cases on a Date)*/
SELECT D.full_date, SUM(F.resolved::INT) AS total_resolved_cases
FROM covid19_tracking_fact_table AS F, onset_date_dimension AS D
WHERE F.onset_date_surrogate_key = D.date_surrogate_key
GROUP BY D.full_date
ORDER BY total_resolved_cases ASC
LIMIT 5

/*Iceberg Query (Bottom-N for Total Resolved Cases on a Date)*/
SELECT D.full_date, SUM(F.fatal::INT) AS total_fatal_cases
FROM covid19_tracking_fact_table AS F, onset_date_dimension AS D
WHERE F.onset_date_surrogate_key = D.date_surrogate_key
GROUP BY D.full_date
ORDER BY total_fatal_cases ASC
LIMIT 5

/*Windowing Query (Total Resolved Cases rank within the Weeks of the Four Selected Monthes)*/
SELECT D.quarter, TO_CHAR(TO_DATE(D.month::text, 'MM'), 'Month') AS Month, D.week_in_year, SUM(F.resolved ::INT) AS total_cases_resolved, 
RANK() OVER (PARTITION BY D.month ORDER BY SUM(F.resolved ::INT) DESC)
FROM covid19_tracking_fact_table AS F, onset_date_dimension AS D
WHERE F.onset_date_surrogate_key = D.date_surrogate_key
GROUP BY (D.quarter, D.month, D.week_in_year)
