/*
______________________________________________________*PROJEKT SQL MAREK MALÝ_____________________
*/

/*
* Tvorba primární tabulky
*/

-- tabulka se mzdami v odvětvích, seřazené podle roku a a odvětvích. Platy jsou v průměru za celý rok

CREATE TABLE t_Marek_maly_project_SQL_primary_final_payroll

SELECT
	cp.industry_branch_code,
	cp.payroll_year,
 	cp.calculation_code,
	cpib.name AS name_of_industry_branch,
	round(avg (cp.value)) AS average_payroll
FROM czechia_payroll cp
JOIN czechia_payroll_unit cpu 
ON cp.unit_code = cpu.code
JOIN czechia_payroll_industry_branch cpib 
ON cp.industry_branch_code = cpib.code 
WHERE value_type_code = '5958'
AND calculation_code = '100'
AND payroll_year > '2005'
AND payroll_year < '2019'
GROUP BY payroll_year, industry_branch_code 
ORDER BY industry_branch_code, payroll_year
;

-- tabulka s potravinami. Všechna data, kategorie a průměrné ceny ve všech regionech za rok.
CREATE TABLE t_Marek_maly_project_SQL_primary_final_price

SELECT
	cp.category_code,
	cpc.name,
	cp.value AS amount_in_CZK,
	REPLACE(CONCAT(cpc.price_value, ' ', cpc.price_unit), '.', ',') AS value_in_units,
	date_format(cp.date_from, '%Y') AS year_from
FROM czechia_price cp 
JOIN czechia_price_category cpc 
ON cp.category_code = cpc.code 
WHERE region_code IS NULL 
GROUP BY category_code, year_from
ORDER BY category_code 
;


-- spojení price a payroll tables do finální tabulky
CREATE TABLE t_Marek_maly_project_SQL_primary_final

SELECT 
	*
FROM t_marek_maly_project_sql_primary_final_payroll tmmpspfpl 
JOIN t_marek_maly_project_sql_primary_final_price tmmpspfp 
ON tmmpspfpl.payroll_year = tmmpspfp.year_from
;
