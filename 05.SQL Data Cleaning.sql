/************** LEFT & RIGHT ***************/

/*1) In the accounts table, there is a column holding the website for each company.
The last three digits specify what type of web address they are using. 
A list of extensions (and pricing) is provided at https://iwantmyname.com/domains. 
Pull these extensions and provide how many of each website type exist in the accounts table. */
SELECT RIGHT(website,3) AS domain_name, COUNT(*)
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;


/*2) There is much debate about how much the name (or even the first letter of a company name) matters. 
Use the accounts table to pull the first letter of each company name to see 
the distribution of company names that begin with each letter (or number).*/
SELECT LEFT(UPPER(name),1) AS letter, COUNT(*) AS total
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;

/*3) Use the accounts table and a CASE statement to create two groups: 
one group of company names that start with a number 
and a second group of those company names that start with a letter. 
What proportion of company names start with a letter?*/
SELECT SUM(num) nums, SUM(letter) letters
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                       THEN 1 ELSE 0 END AS num, 
         CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                       THEN 0 ELSE 1 END AS letter
      FROM accounts) t1;
	  

/*4) Consider vowels as a, e, i, o, and u. 
What proportion of company names start with a vowel, and what percent start with anything else?*/
WITH tbl1 AS(SELECT name,
			CASE 
				WHEN LEFT(UPPER(name),1) IN ('A','E','I','O','U') THEN 1
				ELSE 0
			END AS vowels,
			CASE 
				WHEN LEFT(UPPER(name),1) IN ('A','E','I','O','U') THEN 0
				ELSE 1
			END AS other
		FROM accounts)
		
		
SELECT SUM(vowels), SUM(other)
FROM tbl1;


/****** POSITION & STRPOS *************/

/*1)Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc.*/
SELECT primary_poc, 
	LEFT(primary_poc,STRPOS(primary_poc,' ')-1) AS first_name,
	RIGHT(primary_poc,LENGTH(primary_poc)-STRPOS(primary_poc,' ')) AS last_name
FROM accounts;

/*2) Now see if you can do the same thing for every rep name in the sales_reps table. 
Again provide first and last name columns.*/
SELECT name, 
	LEFT(name,STRPOS(name,' ')-1) AS first_name,
	RIGHT(name,LENGTH(name)-STRPOS(name,' ')) AS last_name
FROM sales_reps;


/****** CONCATE or || *************/

/*1/2)Each company in the accounts table wants to create an email address for each primary_poc. 
The email address should be the first name of the primary_poc . last name primary_poc @ company name .com.*/
WITH tbl1 AS(
	SELECT name,primary_poc,
	LOWER(LEFT(primary_poc,STRPOS(primary_poc,' ')-1)) AS first_name,
	LOWER(RIGHT(primary_poc,LENGTH(primary_poc) - STRPOS(primary_poc,' '))) AS last_name,
	LOWER(REPLACE(name,' ','')) AS company_name
	FROM accounts
)

SELECT CONCAT(first_name,'.',last_name,'@',company_name)
FROM tbl1;


/*We would also like to create an initial password, which they will change after their first log in. 
The first password will be the first letter of the primary_poc's first name (lowercase), 
then the last letter of their first name (lowercase), 
the first letter of their last name (lowercase), 
the last letter of their last name (lowercase), 
the number of letters in their first name, 
the number of letters in their last name, 
and then the name of the company they are working with, 
all capitalized with no spaces.
*/
WITH t1 AS(
	SELECT name,primary_poc,
	LOWER(LEFT(primary_poc,STRPOS(primary_poc,' ')-1)) AS first_name,
	LOWER(RIGHT(primary_poc,LENGTH(primary_poc) - STRPOS(primary_poc,' '))) AS last_name,
	LOWER(REPLACE(name,' ','')) AS company_name
	FROM accounts
)

SELECT first_name,last_name,company_name,
	LEFT(first_name,1) ||
	RIGHT(first_name,1) ||
	LEFT(last_name,1) ||
	RIGHT(last_name,1) ||
	LENGTH(first_name) ||
	LENGTH(last_name) ||
	UPPER(company_name)
FROM t1;


/*******************/
/* date formatting */
select date AS org_date,
(SUBSTR(date,7,4) || '-' ||
SUBSTR(date,1,2) || '-' ||
SUBSTR(date,4,2))::DATE
from sf_crime_data;


/******* COALESCE ************/
SELECT COUNT(primary_poc) AS regular_count,
	COUNT(COALESCE(primary_poc,'no POC')) AS modified_count
FROM accounts;


SELECT COALESCE(a.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, COALESCE(o.account_id, a.id) account_id, o.occurred_at, COALESCE(o.standard_qty, 0) standard_qty, COALESCE(o.gloss_qty,0) gloss_qty, COALESCE(o.poster_qty,0) poster_qty, COALESCE(o.total,0) total, COALESCE(o.standard_amt_usd,0) standard_amt_usd, COALESCE(o.gloss_amt_usd,0) gloss_amt_usd, COALESCE(o.poster_amt_usd,0) poster_amt_usd, COALESCE(o.total_amt_usd,0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id;