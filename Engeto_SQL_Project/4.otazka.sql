/*
______________________________________________________*PROJEKT SQL MAREK MALÝ_____________________
*/

/*
*	4. otázka- Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
*Pro tuto otázku jsem si musel vytvořit dva pohledy. Jeden na meziroční nárust potravin v procentech. 
*Druhý pohled na meziroční nárust mezd. Poté jsem tyto dva pohledy spojil a porovnal meziroční nárust cen a mezd. 
*Vytvořil jsem si nový sloupec ‘more_then_10_percentage ‘, který mi vrátil hodnotu 1, pokud byl nárust větší než 10%, 
*v ostatních případech pak hodnotu 0. Vytvořil jsem další sloupec ‘difference‘, který vypočítal přesnou hodnotu rozdílu 
*mezi cenou potravin a mzdami pouze pro hodnoty 1, tedy pouze pro potraviny, které mají větší meziroční nárust cen, 
*než je nárust mezd. A nakonec jsem si vytáhl pouze údaje o počtu zvýšení z každého roku. 
*Všechna data jsem čerpal z tabulky t_marek_maly_project_sql_primary_final.
*/


-- tabulka 

WITH increase_more_then_ten AS (
SELECT 
	vifp.category_code,
	vifp.name,
	vifp.increase_price_percentage,
	vpi.industry_branch_code,
	vpi.name_of_industry_branch,
	vpi.increase_payroll_percentage,
	vpi.payroll_year,
	CASE 
		WHEN increase_price_percentage - increase_payroll_percentage > 10 THEN 1
		ELSE 0
	END AS  more_then_10_percentages
FROM v_increase_food_prices vifp 
JOIN v_payroll_increase vpi 
ON vpi.payroll_year = vifp.year_from
WHERE increase_price_percentage IS NOT NULL
), 
difference AS (
SELECT 
	payroll_year,
	category_code,
	name,
	increase_price_percentage,
	industry_branch_code,
	name_of_industry_branch,
	increase_payroll_percentage,
	more_then_10_percentages,
	round(increase_price_percentage - increase_payroll_percentage, 2) AS difference
FROM increase_more_then_ten
WHERE more_then_10_percentages = '1'
GROUP BY category_code, increase_payroll_percentage
ORDER BY payroll_year
)
SELECT 
	count(payroll_year) AS number_of_increases,
	payroll_year
FROM difference
GROUP BY payroll_year
ORDER BY number_of_increases desc;

/*
 * postup
 */ 

-- přehled všech kategorií s meziročním nárustem cen potravin
CREATE OR REPLACE VIEW v_increase_food_prices AS;

WITH previous_year AS (
SELECT 
	category_code,
	name,
	value_in_units,
	year_from,
	amount_in_CZK,
	LAG(amount_in_CZK) OVER (PARTITION BY category_code ORDER BY year_from) AS previous_amount
FROM t_marek_maly_project_sql_primary_final tmmpspf
)
SELECT 
	category_code,
	name,
	year_from,
	amount_in_CZK,
	value_in_units,
	round((amount_in_CZK - previous_amount) / previous_amount * 100, 2) AS increase_price_percentage
FROM previous_year
GROUP BY category_code, year_from 
ORDER BY category_code, year_from

-- přehled všech kategorií s meziročním nárustem mezd
CREATE OR REPLACE VIEW v_payroll_increase AS;

WITH previous_year AS (
SELECT 
	payroll_year,
	industry_branch_code,
	name_of_industry_branch,
	average_payroll,
	LAG(average_payroll) OVER (PARTITION BY industry_branch_code ORDER BY payroll_year) AS previous_amount
FROM t_marek_maly_project_sql_primary_final tmmpspf
GROUP BY payroll_year, industry_branch_code 
ORDER BY industry_branch_code, payroll_year 
)
SELECT 
	payroll_year,
	industry_branch_code,
	name_of_industry_branch,
	average_payroll,
	round((average_payroll - previous_amount) / previous_amount * 100, 2) AS increase_payroll_percentage
FROM previous_year
GROUP BY payroll_year, industry_branch_code 
ORDER BY industry_branch_code, payroll_year;