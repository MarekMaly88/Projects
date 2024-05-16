/*
______________________________________________________*PROJEKT SQL MAREK MALÝ_____________________
*/


/*
 *5. Otázka: Má výška HDP vliv na změny ve mzdách a cenách potravin? 
Neboli, pokud HDP vzroste výrazněji v jednom roce, 
projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem? 
Ano. Napriklad v roce 2007 byl nejvyšší nárust GDP o  5, 57%. V tomto roce mzdy vzrostly o 6,79 a potraviny vzrostly o rekonrdních 13,45%. 
Naopak při nejnižším meziročním poklesu v roce 2009 GDP kleslo o 4,66%, mzdy stouply o 3,25% a ceny klesly o rekordních 9,32%.
*/

-- tabulka
WITH percentage_difference AS (
	SELECT 
		YEAR,
		GDP,
		LAG (GDP) OVER (ORDER BY YEAR) AS previous_date_GDP,
		round(( GDP - LAG (GDP) OVER (ORDER BY YEAR)) / LAG (GDP) OVER (ORDER BY YEAR) * 100, 2) AS percent_diff_GDP,
		average_payroll,
		lag(average_payroll) OVER (ORDER BY year) AS previous_date_Payroll,
		round(( average_payroll - lag(average_payroll) OVER (ORDER BY year)) / lag(average_payroll) OVER (ORDER BY year) * 100, 2) AS percent_diff_Payroll,
		average_price,
		lag(average_price) OVER (ORDER BY year) AS previous_date_Price,
		round(( average_price - lag(average_price) OVER (ORDER BY year)) / lag(average_price) OVER (ORDER BY year) * 100, 2) AS percent_diff_Price
	FROM t_Marek_Maly_project_SQL_secondary_final tps
)
SELECT
	YEAR,
	GDP,
	percent_diff_GDP,
	average_payroll,
	percent_diff_Payroll,
	average_price,
	percent_diff_Price
FROM percentage_difference pd
ORDER BY percent_diff_GDP DESC 
;

-- ________POSTUP_____

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