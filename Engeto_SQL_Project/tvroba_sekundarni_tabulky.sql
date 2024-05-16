/*
*______________________________________________________PROJEKT SQL MAREK MALÝ_____________________
*/

/*
* Tvorba sekundární tabulky
*/

-- tvorba pomocné sekundární tabulky
CREATE TABLE t_Marek_Maly_project_SQL_secondary_final_pomocna

SELECT 
	country,
	`year`,
	GDP
FROM economies e 
WHERE year > '2005'
AND year < '2019'
AND country = 'Czech republic'
ORDER BY `year`; 

-- tvorba finální sekundární tabulky
CREATE TABLE t_marek_maly_project_sql_secondary_final

SELECT 
	tsp.country country,
	tsp.YEAR,
	tsp.GDP,
	round(avg(tpf.average_payroll), 0) AS average_payroll,
	round(avg(tpf.amount_in_CZK), 2) AS average_price
FROM t_Marek_Maly_project_SQL_secondary_final_pomocna tsp
JOIN t_marek_maly_project_sql_primary_final tpf
ON tsp.`year` = tpf.payroll_year 
WHERE country  = 'czech republic'
GROUP BY `year` 
;