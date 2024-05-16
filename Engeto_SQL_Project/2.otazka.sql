/*
______________________________________________________*PROJEKT SQL MAREK MALÝ_____________________
*/

/*
 * 2. Otázka: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?))
 * Pro tuto otázku jsem si musel vytvořit čtyři pohledy, v kterých jsou data o množství chleba a mléka, včetně dat o mzdách
 *  v jednotlivých kategotriích v prvním a posledním srovnatelném období. Poté jsem vytvořil dvě tabulky právě z těchto čtyř tabulek. 
 * Všechna data jsem čerpal z tabulky t_marek_maly_project_sql_primary_final.
 * V první tabulce quantity_of_bread_fp jsou data pro první srovntelné období, v druhé tabulce quantity_of_bread_lp data o posledním období. 
 * Nakonec jsem obě tabulky spojil pomocí množinové operace UNION.
 * V první tabulce vidíme množství chleba (111301) v KG a množství mléka (114201) v litrech za průměrné mzdy pro jednotlivé kategorie. 
 * V druhé tabulce vidímě množství chleba (111301) v KG a množství mléka (114201) v litrech za průměrné mzdy pro všechny kategorie.
 * Odpověď:
 * Za první srovnatelné období lze koupit 861,96 kg chleba a 1038,54 litrů mléka.
 * Za první srovnatelné období lze koupit 858,24 kg chleba a 1045,77 litrů mléka.
 */


--  1. TABULKA : průměrné množství chleba a mléka za první a poslední srovnatelné období pro jednotlivé odvětví
SELECT 
	category_code,
	industry_branch_code,
	name_of_industry_branch,
	average_payroll,
	payroll_year,
	name,
	quantity,
	value_in_units
FROM quantity_of_bread_milk_fp 
UNION 
SELECT 
	category_code,
	industry_branch_code,
	name_of_industry_branch,
	average_payroll,
	payroll_year,
	name,
	quantity,
	value_in_units
FROM quantity_of_bread_milk_lp;

-- 2. TABULKA: průměrné množství chleba a mléka za první a poslední srovnatelné období celkově.
SELECT 
	category_code,
	name,
	round(avg(quantity), 2) AS average_quantity,
	payroll_year
FROM quantity_of_bread_milk_fp
GROUP BY category_code
union
SELECT 
	category_code,
	name,
	round(avg(quantity), 2),
	payroll_year 
FROM quantity_of_bread_milk_lp
GROUP BY category_code;

-- ________POSTUP_____

-- první srovnatelné období chleba a mléka
CREATE OR REPLACE VIEW v_first_period_bread_milk AS 

SELECT 
	DISTINCT category_code,
	name,
	amount_in_CZK,
	value_in_units,
	year_from
FROM t_marek_maly_project_sql_primary_final tmmpspf 
WHERE category_code  IN ( '111301', '114201')
AND year_from >= '2006'
ORDER BY year_from  
LIMIT 2
;

-- poslední srovnatelné období chleba a mléka

CREATE OR REPLACE VIEW v_last_period_bread_milk AS 

SELECT 
	DISTINCT category_code,
	name,
	amount_in_CZK,
	value_in_units,
	year_from
FROM t_marek_maly_project_sql_primary_final tmmpspf 
WHERE category_code  IN ('111301', '114201')
ORDER BY year_from DESC
LIMIT 2;

-- první srovantelné období platy všech kategorií
CREATE OR REPLACE VIEW v_first_period_payroll AS 

SELECT 
	DISTINCT industry_branch_code,
	payroll_year,
	name_of_industry_branch,
	average_payroll 
FROM t_marek_maly_project_sql_primary_final tmmpspf 
ORDER BY payroll_year 
LIMIT 19;

-- poseldní srovnatelné období platy všech kategorií
CREATE OR REPLACE VIEW v_last_period_payroll AS 

SELECT 
	DISTINCT industry_branch_code,
	payroll_year,
	name_of_industry_branch,
	average_payroll 
FROM t_marek_maly_project_sql_primary_final tmmpspf 
ORDER BY payroll_year DESC
LIMIT 19;

-- tvorba tabulky poslední srovnatelné období
CREATE TABLE quantity_of_bread_milk_LP
SELECT
	*
FROM v_last_period_bread_milk
JOIN v_last_period_payroll
ON v_last_period_bread_milk.year_from = v_last_period_payroll.payroll_year ;

-- tvorba tabulky první srovnatelné období
CREATE TABLE quantity_of_bread_milk_fp
SELECT 
	*
FROM v_first_period_bread_milk
JOIN v_first_period_payroll
ON v_first_period_bread_milk.year_from = v_first_period_payroll.payroll_year; 

-- přidání nového sloupce s výpočtem průměrného množství
ALTER TABLE quantity_of_bread_milk_fp 
ADD COLUMN quantity DECIMAL(10, 2) GENERATED ALWAYS AS (average_payroll / amount_in_CZK);