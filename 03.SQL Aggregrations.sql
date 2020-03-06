/*Find the total amount of poster_qty paper ordered in the orders table.*/
SELECT SUM(poster_qty) FROM orders;

/*Find the total amount of standard_qty paper ordered in the orders table.*/
SELECT SUM(standard_qty) FROM orders;

/*Find the total dollar amount of sales using the total_amt_usd in the orders table.*/
SELECT SUM(total_amt_usd) FROM orders;

/*Find the total amount spent on standard_amt_usd and gloss_amt_usd paper for each order in the orders table. This should give a dollar amount for each order in the table.*/
SELECT standard_amt_usd + gloss_amt_usd AS total_standard_gloss FROM orders;

/*Find the standard_amt_usd per unit of standard_qty paper. Your solution should use both an aggregation and a mathematical operator.*/
SELECT SUM(standard_amt_usd)/SUM(standard_qty) AS standard_paper_unit_price FROM orders;


/*When was the earliest order ever placed? You only need to return the date.*/
SELECT MIN(occurred_at) FROM orders;

/*Try performing the same query as in question 1 without using an aggregation function.*/
SELECT * FROM orders
ORDER BY occurred_at
LIMIT 1;

/*When did the most recent (latest) web_event occur?*/
SELECT MAX(occurred_at) FROM web_events;

/*Try to perform the result of the previous query without using an aggregation function.*/
SELECT occurred_at FROM web_events
ORDER BY occurred_at DESC
LIMIT 1;

/*Find the mean (AVERAGE) amount spent per order on each paper type, as well as the mean amount of each paper type purchased per order. Your final answer should have 6 values - one for each paper type for the average number of sales, as well as the average amount.*/
SELECT AVG(standard_qty) AS avg_standard_qty, AVG(gloss_qty) AS avg_gloss_qty, AVG(poster_qty) AS avg_poster_qty, 
		AVG(standard_amt_usd) AS avg_standard_amt_usd, AVG(gloss_amt_usd) AS avg_gloss_amt_usd,AVG(poster_amt_usd) AS avg_poster_amt_usd
FROM orders;


/*Via the video, you might be interested in how to calculate the MEDIAN. Though this is more advanced than what we have covered so far try finding - what is the MEDIAN total_usd spent on all orders?*/
/*Since there are 6912 orders - we want the average of the 3457 and 3456 order amounts when ordered. This is the average of 2483.16 and 2482.55. This gives the median of 2482.855*/
SELECT *
FROM (SELECT total_amt_usd
      FROM orders
      ORDER BY total_amt_usd
      LIMIT ((SELECT COUNT(*) FROM orders)/2)) AS Table1
ORDER BY total_amt_usd DESC
LIMIT 2;


/*Which account (by name) placed the earliest order? Your solution should have the account name and the date of the order.*/
SELECT accounts.name, occurred_at
FROM orders
JOIN accounts ON accounts.id = orders.account_id
ORDER BY 2
LIMIT 1;

/*Find the total sales in usd for each account. You should include two columns - the total sales for each company's orders in usd and the company name.*/
SELECT name,SUM(total_amt_usd) AS total_sales
FROM accounts
JOIN orders ON accounts.id = orders.account_id
GROUP BY name;

/*Via what channel did the most recent (latest) web_event occur, which account was associated with this web_event? Your query should return only three values - the date, channel, and account name.*/
SELECT occurred_at, channel, name AS account_name
FROM web_events
JOIN accounts ON accounts.id = web_events.account_id
ORDER BY occurred_at DESC
LIMIT 1;

/*Find the total number of times each type of channel from the web_events was used. Your final table should have two columns - the channel and the number of times the channel was used.*/
SELECT channel,COUNT(*) AS total_number_of_times
FROM web_events
GROUP BY channel
ORDER BY total_number_of_times DESC;

/*Who was the Sales Rep associated with the earliest web_event?*/
SELECT occurred_at, sales_reps.name AS sales_rep_name
FROM web_events
JOIN accounts ON accounts.id = web_events.account_id
JOIN sales_reps ON sales_reps.id = accounts.sales_rep_id
ORDER BY occurred_at
LIMIT 1;

/*Who was the primary contact associated with the earliest web_event?*/
SELECT occurred_at, primary_poc
FROM web_events
JOIN accounts ON accounts.id = web_events.account_id
ORDER BY occurred_at
LIMIT 1;

/*What was the smallest order placed by each account in terms of total usd. Provide only two columns - the account name and the total usd. Order from smallest dollar amounts to largest.*/
SELECT name,MIN(total_amt_usd) AS smalled_order_amount
FROM accounts
JOIN orders ON accounts.id = orders.account_id
GROUP BY name
ORDER BY smalled_order_amount;

/*Find the number of sales reps in each region. Your final table should have two columns - the region and the number of sales_reps. Order from fewest reps to most reps.*/
SELECT region.name AS region_name ,COUNT(*) AS number_of_sales_reps
FROM region
JOIN sales_reps ON region.id = sales_reps.region_id
GROUP BY region_name
ORDER BY number_of_sales_reps;

/*For each account, determine the average amount of each type of paper they purchased across their orders. Your result should have four columns - one for the account name and one for the average quantity purchased for each of the paper types for each account.*/
SELECT accounts.name AS account_name, AVG(standard_qty) AS avg_standard_qty,AVG(gloss_qty) AS avg_gloss_qty,AVG(poster_qty) AS avg_poster_qty
FROM orders
JOIN accounts ON accounts.id = orders.account_id
GROUP BY accounts.id
ORDER BY account_name;

/*For each account, determine the average amount spent per order on each paper type. Your result should have four columns - one for the account name and one for the average amount spent on each paper type.*/
SELECT accounts.name AS account_name, AVG(standard_amt_usd) AS avg_standard_amt_usd,AVG(gloss_amt_usd) AS avg_gloss_amt_usd,AVG(poster_amt_usd) AS avg_poster_amt_usd
FROM orders
JOIN accounts ON accounts.id = orders.account_id
GROUP BY accounts.id
ORDER BY account_name;


/*Determine the number of times a particular channel was used in the web_events table for each sales rep. Your final table should have three columns - the name of the sales rep, the channel, and the number of occurrences. Order your table with the highest number of occurrences first.*/
SELECT sales_reps.name AS sales_rep_name, channel, COUNT(*) AS total_number_of_channel_usage
FROM web_events
JOIN accounts ON accounts.id = web_events.account_id
JOIN sales_reps ON sales_reps.id = accounts.sales_rep_id
GROUP BY sales_rep_name,channel
ORDER BY total_number_of_channel_usage DESC;


/*Determine the number of times a particular channel was used in the web_events table for each region. Your final table should have three columns - the region name, the channel, and the number of occurrences. Order your table with the highest number of occurrences first.*/
SELECT region.name AS region_name, channel, COUNT(*) AS total_occurances
FROM web_events
JOIN accounts ON accounts.id = web_events.account_id
JOIN sales_reps ON sales_reps.id = accounts.sales_rep_id
JOIN region ON region.id = sales_reps.region_id
GROUP BY region_name,channel
ORDER BY total_occurances DESC;

/*Use DISTINCT to test if there are any accounts associated with more than one region.*/

/*The below two queries have the same number of resulting rows (351), 
so we know that every account is associated with only one region. 
If each account was associated with more than one region, the first query should have returned more rows than the second query.
*/
SELECT a.id as "account id", r.id as "region id", 
a.name as "account name", r.name as "region name"
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON r.id = s.region_id;

/*and*/

SELECT DISTINCT id, name
FROM accounts;

/*Have any sales reps worked on more than one account?*/
SELECT sales_reps.id, sales_reps.name, COUNT(*) number_of_accounts
FROM accounts
JOIN sales_reps ON sales_reps.id = accounts.sales_rep_id
GROUP BY 1,2
ORDER BY number_of_accounts;

/*How many of the sales reps have more than 5 accounts that they manage?*/
SELECT sales_reps.name AS sales_rep_name, COUNT(sales_reps.name) AS number_of_managed_accounts
FROM sales_reps
JOIN accounts ON accounts.sales_rep_id = sales_reps.id
GROUP BY sales_rep_name
HAVING COUNT(sales_reps.name) > 5
ORDER BY number_of_managed_accounts DESC;

/*How many accounts have more than 20 orders?*/
SELECT accounts.name AS account_name, COUNT(*) AS number_of_orders
FROM accounts
JOIN orders ON accounts.id = orders.account_id
GROUP BY accounts.id
HAVING COUNT(*) > 20
ORDER BY 1;

/*Which account has the most orders?*/
SELECT accounts.name AS account_name, COUNT(*) AS number_of_orders
FROM accounts
JOIN orders ON accounts.id = orders.account_id
GROUP BY accounts.id
ORDER BY number_of_orders DESC;


/*Which accounts spent more than 30,000 usd total across all orders?*/
SELECT accounts.name AS account_name, SUM(total_amt_usd) AS total_amount
FROM accounts
JOIN orders ON accounts.id = orders.account_id
GROUP BY accounts.id
HAVING SUM(total_amt_usd) > 30000
ORDER BY total_amount DESC;

/*Which accounts spent less than 1,000 usd total across all orders?*/
SELECT accounts.name AS account_name, SUM(total_amt_usd) AS total_amount
FROM accounts
JOIN orders ON accounts.id = orders.account_id
GROUP BY accounts.id
HAVING SUM(total_amt_usd) < 1000
ORDER BY total_amount;

/*Which account has spent the most with us?*/
SELECT accounts.name AS account_name, SUM(total_amt_usd) AS total_amount
FROM accounts
JOIN orders ON accounts.id = orders.account_id
GROUP BY accounts.id
ORDER BY total_amount DESC
LIMIT 1;

/*Which account has spent the least with us?*/
SELECT accounts.name AS account_name, SUM(total_amt_usd) AS total_amount
FROM accounts
JOIN orders ON accounts.id = orders.account_id
GROUP BY accounts.id
ORDER BY total_amount
LIMIT 1;

/*Which accounts used facebook as a channel to contact customers more than 6 times?*/
SELECT accounts.name, channel, COUNT(*) AS total_usage
FROM web_events
JOIN accounts ON accounts.id = web_events.account_id
WHERE channel LIKE 'facebook'
GROUP BY accounts.id, channel
HAVING COUNT(*) > 6
ORDER BY total_usage DESC;

/*Which account used facebook most as a channel?*/
SELECT accounts.name, channel, COUNT(*) AS total_usage
FROM web_events
JOIN accounts ON accounts.id = web_events.account_id
WHERE channel LIKE 'facebook'
GROUP BY accounts.id, channel
ORDER BY total_usage DESC
LIMIT 1;

/*Which channel was most frequently used by most accounts?*/
SELECT channel, COUNT(*) AS total_usage
FROM web_events
GROUP BY channel
ORDER BY total_usage DESC
LIMIT 1;

/*Which channel was most frequently used by most accounts? (including account name)*/
SELECT accounts.name, channel, COUNT(*) AS total_usage
FROM web_events
JOIN accounts ON accounts.id = web_events.account_id
GROUP BY accounts.id, channel
ORDER BY total_usage DESC
