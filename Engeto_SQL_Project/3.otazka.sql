/*
______________________________________________________*PROJEKT SQL MAREK MALÝ_____________________
*/


/*
*Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
*V této tabulce máme procentuální nárust cen potravin. Procenta jsou zprůměrovaná v letech 2006 až 2018.
*V první tabulce vidíme změnu průměrné ceny pro konkrétní produkt s procentálním růstem za každý rok.
*V druhé tabulce už máme pouze jednotlivé produkty s průměrnou změnou ceny. 
*Odpověď:
*Nejnižší procentuální meziroční nárust má potravina Cukr krystal. A to s poklesem 0,26%.
*/

-- 1. TABULKA
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
	year_from AS year,
	avg(amount_in_CZK) AS avg_amount_in_CZK,
	round((amount_in_CZK - previous_amount) / previous_amount * 100, 2) AS Y_on_Y_in_percentages
FROM previous_year
GROUP BY category_code, year_from 
ORDER BY category_code, year_from;

-- 2. TABULKA
WITH previous_year AS (
SELECT 
	category_code,
	name,
	value_in_units,
	year_from,
	amount_in_CZK,
	LAG(amount_in_CZK) OVER (PARTITION BY category_code ORDER BY year_from) AS previous_amount
FROM t_marek_maly_project_sql_primary_final tmmpspf
),
avg_percentages AS (
SELECT 
	category_code,
	name,
	year_from,
	amount_in_CZK,
	round((amount_in_CZK - previous_amount) / previous_amount * 100, 2) AS Y_on_Y_percentages
FROM previous_year
GROUP BY category_code, year_from 
ORDER BY category_code, year_from
)
SELECT 
	category_code,
	name,
	round(avg(Y_on_Y_percentages), 2) AS Y_on_Y_percentages
FROM avg_percentages
GROUP BY category_code
ORDER BY Y_on_Y_percentages;