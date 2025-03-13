Advanced   Functions Sheet

Amazon Athena uses Presto/Trino SQL (a variant of ANSI SQL) as its query engine.
While many SQL functions are compatible across databases, there are some differences in syntax and supported features.




1. Window Functions
ROW_NUMBER():  Assigns a unique row number within a partition
 
  SELECT customer_id, purchase_amount,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY purchase_amount DESC) AS row_num
FROM purchases;


Example Output:
customer_id	purchase_amount	row_num
101	800	1
101	700	2
101	700	3
102	900	1
102	600	2



RANK() Example
RANK() assigns a rank to each row, but skips ranks when there are ties. For example, if two students have the same score, they will receive the same rank, and the next rank will be skipped.

SELECT student_id, score,
       RANK() OVER (ORDER BY score DESC) AS rank
FROM student_scores;
Output:
student_id	score	rank
1	95	1
2	90	2
4	90	2
3	85	4
6	85	4
5	80	6
7	75	7

DENSE_RANK() Example
DENSE_RANK() assigns a rank to each row, but does not skip ranks when there are ties. For example, if two students have the same score, they will receive the same rank, and the next rank will not be skipped.


SELECT student_id, score,
       DENSE_RANK() OVER (ORDER BY score DESC) AS dense_rank
FROM student_scores;
Output:
student_id	score	dense_rank
1	95	1
2	90	2
4	90	2
3	85	3
6	85	3
5	80	4
7	75	5


LAG() – Fetches the previous row’s value
 
  
SELECT customer_id, purchase_amount,
       LAG(purchase_amount, 1, 0) OVER (PARTITION BY customer_id ORDER BY purchase_amount DESC) AS prev_purchase
FROM purchases;
Example Output:
customer_id	purchase_amount	prev_purchase
101	800	0
101	700	800
101	700	700
102	900	700
102	600	900


LEAD() – Fetches the next row’s value
  
SELECT customer_id, purchase_amount,
       LEAD(purchase_amount, 1, 0) OVER (PARTITION BY customer_id ORDER BY purchase_amount DESC) AS next_purchase
FROM purchases;

Example Output:
customer_id	purchase_amount	next_purchase
101	800	700
101	700	700
101	700	900
102	900	600
102	600	0


NTILE(n) – Divides rows into n equal buckets
  
SELECT customer_id, purchase_amount,
       NTILE(3) OVER (PARTITION BY customer_id ORDER BY purchase_amount DESC) AS bucket
FROM purchases;

Example Output:
customer_id	purchase_amount	bucket
101	800	1
101	700	1
101	700	2
102	900	1
102	600	2


2. Common Table Expressions (CTE)
 
  
WITH customer_orders AS (
    SELECT customer_id, COUNT(*) AS order_count
    FROM orders
    GROUP BY customer_id
)
SELECT * FROM customer_orders WHERE order_count > 5;

3. Recursive CTE (For Hierarchical Data) : Athena does not support recursive CTEs.

  
WITH RECURSIVE employee_hierarchy AS (
    SELECT employee_id, manager_id FROM employees WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.manager_id FROM employees e
    JOIN employee_hierarchy h ON e.manager_id = h.employee_id
)
SELECT * FROM employee_hierarchy;


4. CASE WHEN (Conditional Logic in  )
 
  
SELECT customer_id,
       SUM(CASE WHEN order_status = 'Completed' THEN 1 ELSE 0 END) AS completed_orders,
       SUM(CASE WHEN order_status = 'Pending' THEN 1 ELSE 0 END) AS pending_orders
FROM orders
GROUP BY customer_id;

5. PIVOT (Transposing Rows into Columns –   Server Example) : Athena does not support the PIVOT function
 
Athena Example: 

SELECT customer_id,
       SUM(CASE WHEN order_status = 'Completed' THEN order_amount ELSE 0 END) AS completed_amount,
       SUM(CASE WHEN order_status = 'Pending' THEN order_amount ELSE 0 END) AS pending_amount,
       SUM(CASE WHEN order_status = 'Cancelled' THEN order_amount ELSE 0 END) AS cancelled_amount
FROM orders
GROUP BY customer_id;
---------------------------------------------------------------------------------------------------------------------------------------
SELECT * FROM (
    SELECT customer_id, order_status, order_amount FROM orders
) src
PIVOT (
    SUM(order_amount) FOR order_status IN ([Completed], [Pending], [Cancelled])
) AS pivot_table;


6. STRING_AGG (Concatenating grouped values )
   
SELECT customer_id, ARRAY_JOIN(ARRAY_AGG(product_name), ', ') AS product_list
FROM orders
GROUP BY customer_id;


7. JSON Functions (Athena , My  Example)
 
  SELECT order_id, json_extract_scalar(json_data, '$.customer_name') AS customer_name
FROM orders;
 
#Extracting JSON Array Elements

SELECT order_id, element AS json_values
FROM orders
CROSS JOIN UNNEST(CAST(json_extract(json_col, '$') AS ARRAY<JSON>) AS t(element);


8. LATERAL JOIN (For querying array elements separately – Postgre ,   Server)
 
 SELECT o.order_id, j.*
FROM orders o
CROSS JOIN UNNEST(CAST(json_extract(json_col, '$') AS ARRAY<JSON>) AS j;


9. PARTITION BY vs GROUP BY
GROUP BY (Aggregates at group level)
 
  
SELECT customer_id, SUM(order_amount) FROM orders GROUP BY customer_id;
PARTITION BY (Aggregates while keeping original rows)
 
  
SELECT customer_id, order_id, 
       SUM(order_amount) OVER (PARTITION BY customer_id) AS total_orders
FROM orders;


