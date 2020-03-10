/*number of events that occur for each day for each channel*/
SELECT DATE_TRUNC('day',occurred_at) as day, channel, COUNT(*) as number_of_events
FROM web_events
GROUP BY 1,2
ORDER BY 3 DESC;

/*sub query from 1st query */
SELECT * 
FROM 
	(SELECT DATE_TRUNC('day',occurred_at) as day, channel, COUNT(*) as number_of_events
	FROM web_events
	GROUP BY 1,2
	ORDER BY 3 DESC) sub;
	
/*find the average number of events for each channel. Average per day*/
SELECT channel, AVG(number_of_events) AS average_number_of_events
FROM 
	(SELECT DATE_TRUNC('day',occurred_at) AS day, channel, COUNT(*) AS number_of_events
	FROM web_events
	GROUP BY 1,2) sub
GROUP BY 1
ORDER BY 2 DESC;

/*list of orders happended at the first month in P&P history , ordered by occurred_at */
SELECT * 
FROM orders
WHERE DATE_TRUNC('month',occurred_at) =
	(SELECT DATE_TRUNC('month',MIN(occurred_at))
	FROM orders)
ORDER BY occurred_at;

/*list of orders happended at the first day in P&P history , ordered by occurred_at */
SELECT * 
FROM orders
WHERE DATE_TRUNC('day',occurred_at) IN
	(SELECT DATE_TRUNC('day',MIN(occurred_at))
	FROM orders)
ORDER BY occurred_at;


/*average of paper quantity happended at the first month in P&P history*/
SELECT AVG(standard_qty) AS average_standard_paper_quantity,
	AVG(gloss_qty) AS average_gloss_paper_quantity,
	AVG(poster_qty) AS average_poster_paper_quantity,
	SUM(total_amt_usd) AS total_all_paper_sales
FROM orders
WHERE DATE_TRUNC('month',occurred_at) IN
	(SELECT DATE_TRUNC('month',MIN(occurred_at))
		FROM orders);
		
		
/*account id,name and its most frequenet used channel*/
SELECT tbl_3_accounts_with_channels.id, tbl_3_accounts_with_channels.name,
	tbl_3_accounts_with_channels.channel,
	tbl_3_accounts_with_channels.usage_per_channel AS max_usage_times
FROM
	(SElECT accounts.id, accounts.name, channel, COUNT(*) AS usage_per_channel
		FROM accounts
		JOIN web_events ON accounts.id = web_events.account_id
		GROUP BY 1,2,3
		ORDER BY 1) tbl_3_accounts_with_channels
JOIN (SELECT tbl_1_accounts_with_channels.id,tbl_1_accounts_with_channels.name,MAX(usage_per_channel) AS max_channel
		FROM
			(SElECT accounts.id, accounts.name, channel, COUNT(*) AS usage_per_channel
			FROM accounts
			JOIN web_events ON accounts.id = web_events.account_id
			GROUP BY 1,2,3
			ORDER BY 1) tbl_1_accounts_with_channels
		GROUP BY 1,2
		ORDER BY 2) tbl_2_accounts_with_max_channel
ON tbl_3_accounts_with_channels.id = tbl_2_accounts_with_max_channel.id
	AND tbl_3_accounts_with_channels.usage_per_channel = tbl_2_accounts_with_max_channel.max_channel
ORDER BY  tbl_3_accounts_with_channels.id;


/******************************************************************************/

/*sales rep total sales for each region*/
SELECT r.id AS region_id,r.name AS region_name, sr.id AS sales_rep_id, sr.name AS sales_rep_name, SUM(o.total_amt_usd) AS total_sales_per_rep
FROM orders o
JOIN accounts a ON a.id = o.account_id
JOIN sales_reps sr ON sr.id = a.sales_rep_id
JOIN region r ON r.id = sr.region_id
GROUP BY 1,2,3,4
ORDER BY 2,3

/*maximum total sales in each region*/
SELECT tbl1_region_salesrep_with_total_sales.region_id,	MAX(total_sales_per_rep) AS max_sales
FROM
	(SELECT r.id AS region_id,r.name AS region_name, sr.id AS sales_rep_id, sr.name AS sales_rep_name, SUM(o.total_amt_usd) AS total_sales_per_rep
	FROM orders o
	JOIN accounts a ON a.id = o.account_id
	JOIN sales_reps sr ON sr.id = a.sales_rep_id
	JOIN region r ON r.id = sr.region_id
	GROUP BY 1,2,3,4
	ORDER BY 2,3) tbl1_region_salesrep_with_total_sales
GROUP BY 1

/*** Final ***/
/*1) Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.*/
SELECT region_name,sales_rep_name,total_sales_per_rep AS largest_amount_of_sales
FROM 
	(SELECT r.id AS region_id,r.name AS region_name, sr.id AS sales_rep_id, sr.name AS sales_rep_name, 
	 	SUM(o.total_amt_usd) AS total_sales_per_rep
	FROM orders o
	JOIN accounts a ON a.id = o.account_id
	JOIN sales_reps sr ON sr.id = a.sales_rep_id
	JOIN region r ON r.id = sr.region_id
	GROUP BY 1,2,3,4
	ORDER BY 2,3) tbl3_region_salesrep_with_total_sales
JOIN (SELECT tbl1_region_salesrep_with_total_sales.region_id,MAX(total_sales_per_rep) AS max_sales
	FROM
		(SELECT r.id AS region_id,r.name AS region_name, sr.id AS sales_rep_id, sr.name AS sales_rep_name, SUM(o.total_amt_usd) AS total_sales_per_rep
		FROM orders o
		JOIN accounts a ON a.id = o.account_id
		JOIN sales_reps sr ON sr.id = a.sales_rep_id
		JOIN region r ON r.id = sr.region_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3) tbl1_region_salesrep_with_total_sales
	GROUP BY 1) tbl2_region_with_max_sales
ON tbl3_region_salesrep_with_total_sales.region_id = tbl2_region_with_max_sales.region_id
	AND tbl3_region_salesrep_with_total_sales.total_sales_per_rep = tbl2_region_with_max_sales.max_sales
ORDER BY 3 DESC;

/****************************************/
/*largest sales region*/
SELECT r.id AS region_id,r.name AS region_name, SUM(o.total_amt_usd) AS region_total_sales
FROM orders o
JOIN accounts a ON a.id = o.account_id
JOIN sales_reps sr ON sr.id = a.sales_rep_id
JOIN region r ON r.id = sr.region_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 1;

/*total numbers of orders per region */
SELECT r.id AS region_id,r.name AS region_name, COUNT(*) AS total_number_of_orders
FROM orders o
JOIN accounts a ON a.id = o.account_id
JOIN sales_reps sr ON sr.id = a.sales_rep_id
JOIN region r ON r.id = sr.region_id
GROUP BY 1,2

/*** Final ***/
/*2) For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed?*/
SELECT tbl1_largest_sales_region.region_id, tbl1_largest_sales_region.region_name, total_number_of_orders
FROM
	(SELECT r.id AS region_id,r.name AS region_name, SUM(o.total_amt_usd) AS region_total_sales
	FROM orders o
	JOIN accounts a ON a.id = o.account_id
	JOIN sales_reps sr ON sr.id = a.sales_rep_id
	JOIN region r ON r.id = sr.region_id
	GROUP BY 1,2
	ORDER BY 3 DESC
	LIMIT 1) tbl1_largest_sales_region
JOIN (SELECT r.id AS region_id,r.name AS region_name, COUNT(*) AS total_number_of_orders
	FROM orders o
	JOIN accounts a ON a.id = o.account_id
	JOIN sales_reps sr ON sr.id = a.sales_rep_id
	JOIN region r ON r.id = sr.region_id
	GROUP BY 1,2) tbl2_region_with_total_orders
ON tbl1_largest_sales_region.region_id = tbl2_region_with_total_orders.region_id

/*version 2 */
SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (
      SELECT MAX(total_amt)
      FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
              FROM sales_reps s
              JOIN accounts a
              ON a.sales_rep_id = s.id
              JOIN orders o
              ON o.account_id = a.id
              JOIN region r
              ON r.id = s.region_id
              GROUP BY r.name) sub);

/******************************************************/

/* account with largest standard paper orders */
SELECT a.id AS account_id, SUM(o.standard_qty) AS total_standard_qty
FROM orders o
JOIN accounts a ON a.id = o.account_id
WHERE o.standard_qty > 0
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

/*max standard paper orders number */
SELECT MAX(total_standard_qty)
FROM
	(SELECT a.id AS account_id, SUM(o.standard_qty) AS total_standard_qty
	FROM orders o
	JOIN accounts a ON a.id = o.account_id
	WHERE o.standard_qty > 0
	GROUP BY 1) tbl1_account_with_std_paper_orders
	
	
/*********************************************/
/*For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, 
how many web_events did they have for each channel?*/


/*What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?*/


/*What is the lifetime average amount spent in terms of total_amt_usd, including only the companies 
that spent more per order, on average, than the average of all orders.*/


/**********************************************/

/**** CTE Common Table Expressions ****/

/*find the average number of events for each channel per day.*/
WITH events as(
	SELECT DATE_TRUNC('day',occurred_at) AS day,
		channel, COUNT(*) as events
	FROM web_events 
	GROUP BY 1,2)
	
SELECT channel, AVG(events) AS average_events
FROM events
GROUP BY channel
ORDER BY 2 DESC;


/* CTE multiple table format */
WITH table1 AS (
          SELECT *
          FROM web_events),

     table2 AS (
          SELECT *
          FROM accounts)


SELECT *
FROM table1
JOIN table2
ON table1.account_id = table2.id;


/*1) Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.*/
WITH tbl1_region_salesrep_with_total_sales AS
	(SELECT r.id AS region_id,r.name AS region_name, sr.id AS sales_rep_id, sr.name AS sales_rep_name, 
			SUM(o.total_amt_usd) AS total_sales_per_rep
		FROM orders o
		JOIN accounts a ON a.id = o.account_id
		JOIN sales_reps sr ON sr.id = a.sales_rep_id
		JOIN region r ON r.id = sr.region_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3),
		
	tbl2_region_with_max_sales AS 
		(SELECT tbl1_region_salesrep_with_total_sales.region_id,MAX(total_sales_per_rep) AS max_sales
			FROM tbl1_region_salesrep_with_total_sales
			GROUP BY 1) 
		
		
SELECT region_name,sales_rep_name,total_sales_per_rep AS largest_amount_of_sales
FROM tbl1_region_salesrep_with_total_sales
JOIN tbl2_region_with_max_sales
ON tbl1_region_salesrep_with_total_sales.region_id = tbl2_region_with_max_sales.region_id
	AND tbl1_region_salesrep_with_total_sales.total_sales_per_rep = tbl2_region_with_max_sales.max_sales
ORDER BY 3 DESC;