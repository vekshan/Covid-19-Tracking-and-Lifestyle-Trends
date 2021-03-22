/*Drill down query*/
SELECT D.year, D.month, D.day, SUM(F.unresolved::INT) AS total_positive_cases
FROM covid19_tracking_fact_table AS F, date_dimension AS D
WHERE F.reported_date_surrogate_key = D.date_surrogate_key AND F.resolved = TRUE AND D.month = 04 AND D.year = 2020
GROUP BY (D.year, D.month, D.day)
ORDER BY D.year, D.month, D.day

/*Drill down query (Actual)*/
SELECT D.full_date, COALESCE(sum(CASE WHEN F.unresolved THEN 1 ELSE 0 END), 0) as total_unresolved_cases
FROM covid19_tracking_fact_table AS F, date_dimension AS D
WHERE F.reported_date_surrogate_key = D.date_surrogate_key AND (D.full_date >= '2020-10-01' AND D.full_date <= '2020-10-31')
GROUP BY (D.full_date)
ORDER BY D.full_date

/*Roll up query*/
SELECT L.city, SUM(F.fatal::INT) AS total_fatal_cases
FROM covid19_tracking_fact_table AS F, phu_location_dimension AS L
WHERE F.phu_location_surrogate_key = L.phu_location_surrogate_key
GROUP BY ROLLUP(L.city)
ORDER BY L.city

/*Roll up Query (Actual)*/
SELECT L.city, (CASE WHEN L.city = 'Ottawa' THEN 'Ottawa' ELSE 'Toronto' END) AS region, SUM(F.fatal::INT) AS total_fatal_cases
FROM covid19_tracking_fact_table AS F, phu_location_dimension AS L
WHERE F.phu_location_surrogate_key = L.phu_location_surrogate_key
GROUP BY ROLLUP(region, L.city)
ORDER BY L.city

/*Roll up Query*/
SELECT L.city, I.age_group, I.gender, (CASE WHEN L.city = 'Ottawa' THEN 'Ottawa' ELSE 'Toronto' END) AS region, SUM(F.fatal::INT) AS total_fatal_cases
FROM covid19_tracking_fact_table AS F, phu_location_dimension AS L, patient_dimension as I
WHERE F.phu_location_surrogate_key = L.phu_location_surrogate_key AND F.patient_surrogate_key = I.patient_surrogate_key
GROUP BY I.age_group, I.gender, ROLLUP(region, L.city)
ORDER BY L.city

/*Dice Query*/
SELECT M.subregion, M.parks, M.transit_stations, W.precipitation, SUM(F.fatal::INT) AS total_fatal_cases
FROM covid19_tracking_fact_table AS F, mobility_dimension AS M, weather_dimension as W
WHERE F.mobility_surrogate_key = M.mobility_surrogate_key AND F.weather_surrogate_key = W.weather_surrogate_key 
AND M.subregion in ('Ottawa Division', 'Toronto Division') AND W.precipitation > 0
GROUP BY (M.subregion, M.parks, M.transit_stations, W.precipitation)

/* Dice Query*/
SELECT M.subregion, M.parks, M.transit_stations, W.precipitation, SUM(F.unresolved::INT) AS total_unresolved_cases
FROM covid19_tracking_fact_table AS F, mobility_dimension AS M, weather_dimension as W
WHERE F.mobility_surrogate_key = M.mobility_surrogate_key AND F.weather_surrogate_key = W.weather_surrogate_key 
AND M.subregion in ('Ottawa Division', 'Toronto Division') AND W.precipitation > 0
GROUP BY (M.subregion, M.parks, M.transit_stations, W.precipitation)

/*Dice Query*/
SELECT M.subregion, M.parks, M.transit_stations, W.daily_high_temperature, COUNT(*) AS total_cases
FROM covid19_tracking_fact_table AS F, mobility_dimension AS M, weather_dimension as W
WHERE F.mobility_surrogate_key = M.mobility_surrogate_key AND F.weather_surrogate_key = W.weather_surrogate_key 
AND M.subregion in ('Ottawa Division', 'Toronto Division') AND W.daily_low_temperature 
GROUP BY (M.subregion, M.parks, M.transit_stations, W.daily_high_temperature)

/*Combined OLAP operations*/
SELECT M.subregion, W.daily_low_temperature, W.precipitation, SUM(F.resolved::INT) AS total_resolved_cases, 
SUM(F.unresolved::INT) AS total_unresolved_cases, SUM(F.fatal::INT) AS total_fatal_cases
FROM covid19_tracking_fact_table AS F, mobility_dimension AS M, weather_dimension as W
WHERE F.mobility_surrogate_key = M.mobility_surrogate_key AND F.weather_surrogate_key = W.weather_surrogate_key
AND M.subregion in ('Ottawa Division', 'Toronto Division') AND W.daily_low_temperature <= 4 AND W.precipitation >= 0
GROUP BY (M.subregion, W.daily_low_temperature, W.precipitation)

/*Iceberg Query (Top-N)*/
SELECT D.full_date, SUM(F.resolved::INT) AS total_resolved_cases
FROM covid19_tracking_fact_table AS F, date_dimension AS D
WHERE F.reported_date_surrogate_key = D.date_surrogate_key
GROUP BY D.full_date
ORDER BY total_resolved_cases DESC
LIMIT 5


/*Iceberg Query (Bottom-N)*/
SELECT D.full_date, SUM(F.resolved::INT) AS total_resolved_cases
FROM covid19_tracking_fact_table AS F, date_dimension AS D
WHERE F.reported_date_surrogate_key = D.date_surrogate_key
GROUP BY D.full_date
ORDER BY total_resolved_cases ASC
LIMIT 5