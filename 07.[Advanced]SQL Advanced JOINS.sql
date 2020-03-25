/*Say you're an analyst at Parch & Posey and you want to see:
each account who has a sales rep and each sales rep that has an account 
(all of the columns in these returned rows will be full)

but also each account that does not have a sales rep and each sales rep that does not have an account 
(some of the columns in these returned rows will be empty)*/
SELECT accounts.id,accounts.name,sales_reps.id, sales_reps.name
FROM accounts
FULL OUTER JOIN sales_reps ON accounts.sales_rep_id = sales_reps.id;

/* To see rows where 1) Companies without sales rep OR 2)sales rep without accouts */
SELECT accounts.id,accounts.name,sales_reps.id, sales_reps.name
FROM accounts
FULL OUTER JOIN sales_reps ON accounts.sales_rep_id = sales_reps.id
WHERE accounts.sales_rep_id IS NULL OR sales_reps.id IS NULL;


/*Inequality Join
 write a query that left joins the accounts table and the sales_reps tables on each sale rep's ID number 
 and joins it using the < comparison operator on accounts.primary_poc and sales_reps.name, like so:
accounts.primary_poc < sales_reps.name
The query results should be a table with three columns: 
the account name (e.g. Johnson Controls), the primary contact name (e.g. Cammy Sosnowski), 
and the sales representative's name (e.g. Samuel Racine)*/
SELECT accounts.name,accounts.primary_poc,sales_reps.name
FROM accounts
LEFT JOIN sales_reps
ON accounts.sales_rep_id = sales_reps.id
AND accounts.primary_poc < sales_reps.name


/*Getting list of web events which happens one day duration one after another*/
SELECT we1.id AS we_id,
       we1.account_id AS we1_account_id,
       we1.occurred_at AS we1_occurred_at,
       we1.channel AS we1_channel,
       we2.id AS we2_id,
       we2.account_id AS we2_account_id,
       we2.occurred_at AS we2_occurred_at,
       we2.channel AS we2_channel
  FROM web_events we1 
 LEFT JOIN web_events we2
   ON we1.account_id = we2.account_id
  AND we1.occurred_at > we2.occurred_at
  AND we1.occurred_at <= we2.occurred_at + INTERVAL '1 day'
ORDER BY we1.account_id, we2.occurred_at


/* UNION ALL vs UNION */
/*Nice! UNION only appends distinct values. 
More specifically, when you use UNION, the dataset is appended, and any rows in the appended table 
that are exactly identical to rows in the first table are dropped. 

If you’d like to append all the values from the second table, use UNION ALL. 
You’ll likely use UNION ALL far more often than UNION.*/

SELECT * FROM accounts a1
WHERE name LIKE 'Walmart'
UNION ALL
SELECT * FROM accounts a2
WHERE name LIKE 'Disney'

/*Perform the union in your first query (under the Appending Data via UNION header) in a common table expression and 
name it double_accounts. Then do a COUNT the number of times a name appears in the double_accounts table. 
If you do this correctly, your query results should have a count of 2 for each name.*/
WITH double_accounts AS(
	SELECT * FROM accounts a1
	UNION ALL
	SELECT * FROM accounts a2)

SELECT name, COUNT(*)
FROM double_accounts
GROUP BY name;

/* PERFORMANCE TUNING */
EXPLAIN
SELECT *
FROM web_events
WHERE occurred_at >= '2016-01-01'
AND occurred_at < '2016-02-01'
LIMIT 100;