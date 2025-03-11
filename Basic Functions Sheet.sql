
1. DATE AND TIME FUNCTIONS
Get yesterday’s date in Athena
SELECT DATE_ADD('day', -1, current_date) AS yesterday_date;

Extract year, month, day from a timestamp
SELECT event_time, 
       year(event_time) AS event_year, 
       month(event_time) AS event_month, 
       day(event_time) AS event_day
FROM events;

Find the first and last day of the previous month
SELECT 
    DATE_TRUNC('month', DATE_ADD('month', -1, current_date)) AS first_day_prev_month,
    LAST_DAY(DATE_ADD('month', -1, current_date)) AS last_day_prev_month;


2. STRING MANIPULATION IN ATHENA
Remove whitespace from both sides of a string
SELECT TRIM('  hello world  ') AS cleaned_text;
Extract a portion of a string using SPLIT_PART()
    
SELECT 
    email, 
    SPLIT_PART(email, '@', 1) AS username, 
    SPLIT_PART(email, '@', 2) AS domain 
FROM users;
Convert a string to lowercase
   
    
    
SELECT LOWER(customer_name) AS lowercase_name FROM customers;
Replace text inside a string
   
    
    
SELECT REPLACE(phone_number, '-', '') AS sanitized_phone FROM customers;
3. ARRAY FUNCTIONS IN ATHENA
Convert a string to an array
   
    
    
SELECT SPLIT('apple,banana,grape', ',') AS fruit_array;
Find the size of an array
   
    
    
SELECT ARRAY_LENGTH(SPLIT('apple,banana,grape', ',')) AS array_size;
Flatten an array using UNNEST()
   
    
    
SELECT fruit 
FROM (SELECT SPLIT('apple,banana,grape', ',') AS fruits) 
CROSS JOIN UNNEST(fruits) AS t(fruit);
4. CONDITIONAL AGGREGATION
Count users with specific conditions
   
    
    
SELECT 
    COUNT(*) AS total_users,
    COUNT(CASE WHEN status = 'active' THEN 1 END) AS active_users,
    COUNT(CASE WHEN status = 'inactive' THEN 1 END) AS inactive_users
FROM users;
5. HANDLING NULL VALUES
Replace NULL values with a default value
   
    
    
SELECT COALESCE(phone_number, 'Not Provided') AS contact_info FROM customers;
Check if a column is NULL
   
    
    
SELECT user_id, 
       CASE WHEN email IS NULL THEN 'No Email' ELSE 'Has Email' END AS email_status
FROM users;
6. ROLLING AGGREGATIONS (MOVING AVERAGES, SUMS)
Calculate a 7-day moving average
   
    
    
SELECT customer_id, purchase_date, purchase_amount,
       AVG(purchase_amount) OVER (
           PARTITION BY customer_id 
           ORDER BY purchase_date 
           ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
       ) AS moving_avg
FROM purchases;
7. PIVOT DATA USING CONDITIONAL SUMS
Pivot status counts into separate columns
   
    
    
SELECT 
    customer_id,
    SUM(CASE WHEN order_status = 'Completed' THEN 1 ELSE 0 END) AS completed_orders,
    SUM(CASE WHEN order_status = 'Pending' THEN 1 ELSE 0 END) AS pending_orders,
    SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders
FROM orders
GROUP BY customer_id;
8. RANKING CUSTOMERS BASED ON SPEND
Find top spenders per month
   
    
    
SELECT customer_id, order_month, total_spend,
       RANK() OVER (PARTITION BY order_month ORDER BY total_spend DESC) AS rank
FROM (
    SELECT customer_id, 
           DATE_FORMAT(order_date, '%Y-%m') AS order_month, 
           SUM(order_amount) AS total_spend
    FROM orders
    GROUP BY customer_id, DATE_FORMAT(order_date, '%Y-%m')
) t;
9. IDENTIFY DUPLICATES
Find duplicate email addresses
   
    
    
SELECT email, COUNT(*) AS occurrences
FROM users
GROUP BY email
HAVING COUNT(*) > 1;
10. FIND USERS WITH NO ORDERS (EXCLUDING INNER JOIN)
Use LEFT JOIN to find users who never placed an order
   
    
    
SELECT u.customer_id, u.customer_name
FROM customers u
LEFT JOIN orders o ON u.customer_id = o.customer_id
WHERE o.customer_id IS NULL;
11. STRING SEARCH & PATTERN MATCHING
Find email addresses with a specific domain
   
    
    
SELECT * FROM users WHERE email LIKE '%@gmail.com';
Extract numbers from a string using REGEXP_EXTRACT
   
    
    
SELECT REGEXP_EXTRACT('Order12345', '[0-9]+') AS extracted_number;
12. WORKING WITH JSON IN ATHENA
Parse JSON and extract values
   
    
    
SELECT 
    JSON_EXTRACT_SCALAR(json_data, '$.customer_name') AS customer_name,
    JSON_EXTRACT_SCALAR(json_data, '$.order_id') AS order_id
FROM orders;
Extract an array from JSON and unnest it
   
    
    
SELECT order_id, items.value AS product_name
FROM orders 
CROSS JOIN UNNEST(JSON_PARSE(order_details)) AS items(value);
13. STRING CONCATENATION IN ATHENA
Concatenate first name and last name
   
    
    
SELECT CONCAT(first_name, ' ', last_name) AS full_name FROM users;
14. COUNT DISTINCT USERS PER DAY
   
    
    
SELECT event_date, COUNT(DISTINCT user_id) AS unique_users
FROM event_logs
GROUP BY event_date;
15. GENERATE SEQUENCES IN ATHENA (for missing dates)
Create a range of dates dynamically
   
    
    
WITH date_series AS (
    SELECT DATE_ADD('day', i, DATE('2024-01-01')) AS generated_date
    FROM UNNEST(SEQUENCE(0, 30)) AS t(i)
)
SELECT generated_date FROM date_series;