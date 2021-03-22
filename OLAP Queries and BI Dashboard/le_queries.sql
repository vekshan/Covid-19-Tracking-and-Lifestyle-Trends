a-ii)
SELECT D.Day, D.Week_in_Year, D.Month, D.Year, SUM(F.Resolved::INT) AS total_resolve_cases
FROM covid19_tracking_fact_table AS F, date_dimension AS D
WHERE F.resolved = TRUE AND D.Week_in_Year = 14 AND D.month = 04 AND D.year = 2020
GROUP BY (D.year, D.month, D.Week_in_Year, D.day)
ORDER BY D.year, D.month, D.Week_in_Year, D.day

b-i) 
SELECT L.phu_name, SUM(F.resolved ::INT) AS total_cases_resolved, SUM(F.unresolved ::INT) AS total_cases_unresolved, SUM(F.fatal ::INT) AS total_cases_fatal, COUNT(P.patient_surrogate_key) AS total_cases
FROM covid19_tracking_fact_table AS F 
INNER JOIN patient_dimension P ON F.patient_surrogate_key = P.patient_surrogate_key
INNER JOIN phu_location_dimension L ON F.phu_location_surrogate_key = L.phu_location_surrogate_key
GROUP BY L.phu_name

d-iv) 
SELECT M.Subregion AS mobility, SUM(F.resolved ::INT) AS total_cases_resolved, SUM(F.unresolved ::INT) AS total_cases_unresolved, SUM(F.fatal ::INT) AS total_cases_fatal, COUNT(*) AS total_cases
FROM covid19_tracking_fact_table AS F, mobility_dimension AS M
WHERE F.mobility_surrogate_key = M.mobility_surrogate_key AND M.Subregion = 'Regional Municipality of Peel' OR M.Subregion = 'Ottawa Division'
GROUP BY M.mobility_surrogate_key