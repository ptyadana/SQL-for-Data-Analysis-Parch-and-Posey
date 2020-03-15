SELECT  standard_qty,
	DATE_TRUNC('month',occurred_at) AS month,
	SUM(standard_qty) OVER (PARTITION BY DATE_TRUNC('month',occurred_at) ORDER BY occurred_at) AS running_total
FROM orders;

/*create a running total of standard_amt_usd (in the orders table) over order time with no date truncation. 
Your final table should have two columns: 
one with the amount being added for each new row, and a second with the running total.*/
SELECT standard_amt_usd, 
	SUM(standard_amt_usd) OVER (ORDER BY occurred_at) AS running_total
FROM orders

/*create a running total of standard_amt_usd (in the orders table) over order time, 
but this time, date truncate occurred_at by year and partition by that same year-truncated occurred_at variable. 
Your final table should have three columns: One with the amount being added for each row, 
one for the truncated date, and a final column with the running total within each year.*/
SELECT standard_amt_usd, 
	DATE_TRUNC('year',occurred_at) AS year,
	SUM(standard_amt_usd) OVER (PARTITION BY DATE_TRUNC('year',occurred_at) ORDER BY occurred_at) AS running_total
FROM orders

/*-------------------------------*/

/*Ranking Total Paper Ordered by Account
Select the id, account_id, and total variable from the orders table, 
then create a column called total_rank that ranks this total amount of paper ordered 
(from highest to lowest) for each account using a partition. Your final table should have these four columns.*/
SELECT id, account_id, total,
	RANK() OVER (PARTITION BY account_id ORDER BY total DESC) AS total_rank
FROM orders;


SELECT id,
		account_id,
		standard_qty,
		DATE_TRUNC('month',occurred_at) AS month,
		DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS dense_rank,
		SUM(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS sum_standard_qty,
		COUNT(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS count_standard_aty,
		AVG(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS  average_standard_qty,
		MIN(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS min_standard_qty,
		MAX(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS max_standard_qty
FROM orders;


/*-------------------------------*/

/*-------------- Window Aliases -----------------*/

SELECT id,
		account_id,
		standard_qty,
		DATE_TRUNC('month',occurred_at) AS month,
		DENSE_RANK() OVER main_window AS dense_rank,
		SUM(standard_qty) OVER main_window AS sum_standard_qty,
		COUNT(standard_qty) OVER main_window AS count_standard_aty,
		AVG(standard_qty) OVER main_window AS  average_standard_qty,
		MIN(standard_qty) OVER main_window AS min_standard_qty,
		MAX(standard_qty) OVER main_window AS max_standard_qty
FROM orders
WINDOW main_window AS (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at))


SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER account_year_window AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER account_year_window AS count_total_amt_usd,
       AVG(total_amt_usd) OVER account_year_window AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER account_year_window AS min_total_amt_usd,
       MAX(total_amt_usd) OVER account_year_window AS max_total_amt_usd
FROM orders
WINDOW account_year_window AS (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at))


/* --------------------------------------------------  */

/* ----------------- LEAD and LAG  ------------------------*/
/*LAG */
SELECT account_id,
       standard_sum,
       LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag,
       standard_sum - LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag_difference
FROM (
       SELECT account_id,
       SUM(standard_qty) AS standard_sum
       FROM orders 
       GROUP BY 1
      ) sub


/* LELAD */
SELECT account_id,
       standard_sum,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) AS lead,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) - standard_sum AS lead_difference
FROM (
SELECT account_id,
       SUM(standard_qty) AS standard_sum
       FROM orders 
       GROUP BY 1
     ) sub
	 
	 
/*you want to determine how the current order's total revenue 
("total" meaning from sales of all types of paper) 
compares to the next order's total revenue.
there should be four columns: occurred_at, total_amt_usd, lead, and lead_difference.*/

SELECT occurred_at,
       total_amt_usd,
       LEAD(total_amt_usd) OVER (ORDER BY total_amt_usd) AS lead,
       LEAD(total_amt_usd) OVER (ORDER BY total_amt_usd) - total_amt_usd AS lead_difference
FROM (
SELECT occurred_at,
       SUM(total_amt_usd) AS total_amt_usd
  FROM orders 
 GROUP BY 1
 ) sub
 
 /*--------------------------------------------------*/
 
 /* Percentile */
 
SELECT id, account_id, occurred_at,standard_qty,
	NTILE(4) OVER (ORDER BY standard_qty) AS quartile,
	NTILE(5) OVER (ORDER BY standard_qty) AS quintile,
	NTILE(100) OVER (ORDER BY standard_qty) AS percentile
FROM orders
ORDER BY standard_qty DESC;


/*Use the NTILE functionality to divide the accounts into 4 levels in terms of the amount of standard_qty 
for their orders. Your resulting table should have the account_id, the occurred_at time for each order, 
the total amount of standard_qty paper purchased, and one of four levels in a standard_quartile column.*/
SELECT account_id, occurred_at,standard_qty,
	NTILE(4) OVER (PARTITION BY account_id ORDER BY standard_qty) AS standard_quartile
FROM orders
ORDER BY account_id DESC;

/*Use the NTILE functionality to divide the accounts into two levels in terms of the amount of gloss_qty 
for their orders. Your resulting table should have the account_id, 
the occurred_at time for each order, the total amount of gloss_qty paper purchased, 
and one of two levels in a gloss_half column.
*/
SELECT account_id, occurred_at,gloss_qty,
	NTILE(2) OVER (PARTITION BY account_id ORDER BY gloss_qty) AS gloss_half
FROM orders
ORDER BY account_id DESC;


/*Use the NTILE functionality to divide the orders for each account into 100 levels 
in terms of the amount of total_amt_usd for their orders. 
Your resulting table should have the account_id, the occurred_at time for each order, 
the total amount of total_amt_usd paper purchased,
and one of 100 levels in a total_percentile column.*/
SELECT account_id, occurred_at,total_amt_usd,
	NTILE(100) OVER (PARTITION BY account_id ORDER BY total_amt_usd) AS total_percentile
FROM orders
ORDER BY account_id DESC;