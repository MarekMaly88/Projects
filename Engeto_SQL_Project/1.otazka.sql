/*
______________________________________________________*PROJEKT SQL MAREK MALÝ_____________________
*/

/*
*1. OTÁZKA: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
*V první tabulce vidíme porovnání mezd pro jednotlivé kategorie v letech 2006 až 2018. 
*V druhé tabulce vidíme pouze data s rokem, kdy došlo k poklesu mzdy. A jen pro zajímavost maximální procentuální rozdíl.
*Pro lepší přehled i odpověď, zda platy stoupají, či klesají a to včetně procentuálního rozdílu.
*Odpověď:
Mzdy rostou v průběhu let pouze v kategorii Těžba a dobývání, Doprava a skladování, Administrativní a podpůrné činnosti, Zdravotní a sociální péče
a nakonec Ostatní činnosti. V ostatních kategiriích mzdy v průběhu let klesají. Pro zajímavost, v druhé tabulce můžeme vidět přesně v 
jakém roce mzdy klesly.
*/

-- 1. TABULKA
SELECT 
	DISTINCT payroll_year,
	industry_branch_code,
	name_of_industry_branch,
	average_payroll,
--	LAG (average_payroll) OVER (PARTITION BY industry_branch_code  ORDER BY payroll_year) AS previous_value,
	round((average_payroll - LAG (average_payroll) OVER (PARTITION BY industry_branch_code  ORDER BY payroll_year)) / LAG (average_payroll) OVER (PARTITION BY industry_branch_code  ORDER BY payroll_year) * 100, 2) AS percentage_difference,
	CASE 
		WHEN (average_payroll) < LAG (average_payroll) OVER (PARTITION BY industry_branch_code  ORDER BY payroll_year) THEN 'decreasing'
		ELSE 'increasing'
	END AS increasing_or_decreasing
FROM t_marek_maly_project_sql_primary_final tmmpspf
GROUP BY payroll_year, industry_branch_code
ORDER BY industry_branch_code, payroll_year
;

-- 2. TABULKA	
WITH difference AS (
	SELECT 
		DISTINCT payroll_year,
		industry_branch_code,
		name_of_industry_branch,
		average_payroll,
		LAG (average_payroll) OVER (PARTITION BY industry_branch_code  ORDER BY payroll_year) AS previous_value,
		round((average_payroll - LAG (average_payroll) OVER (PARTITION BY industry_branch_code  ORDER BY payroll_year)) / LAG (average_payroll) OVER (PARTITION BY industry_branch_code  ORDER BY payroll_year) * 100, 2) AS percentage_difference,
		CASE 
			WHEN (average_payroll) < LAG (average_payroll) OVER (PARTITION BY industry_branch_code  ORDER BY payroll_year) THEN 'decreasing'
			ELSE 'increasing'
		END AS increasing_or_decreasing
	FROM t_marek_maly_project_sql_primary_final tmmpspf
	GROUP BY payroll_year, industry_branch_code 
	ORDER BY industry_branch_code, payroll_year
)
SELECT 
	payroll_year,
	industry_branch_code,
	name_of_industry_branch,
	increasing_or_decreasing,
	max(percentage_difference) AS percentage_difference
FROM difference
GROUP BY industry_branch_code, increasing_or_decreasing
;