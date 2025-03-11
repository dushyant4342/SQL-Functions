Advanced   Functions Sheet
1. Window Functions
ROW_NUMBER() – Assigns a unique row number within a partition
 
  
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
RANK() – Assigns a rank, skipping numbers for ties
 
  
SELECT customer_id, purchase_amount,
       RANK() OVER (PARTITION BY customer_id ORDER BY purchase_amount DESC) AS rank
FROM purchases;
Example Output:
customer_id	purchase_amount	rank
101	800	1
101	700	2
101	700	2
102	900	1
102	600	2
Key Difference: Rank skips numbers when there are ties.

DENSE_RANK() – Assigns a rank, without skipping numbers for ties
 
  
SELECT customer_id, purchase_amount,
       DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY purchase_amount DESC) AS dense_rank
FROM purchases;
Example Output:
customer_id	purchase_amount	dense_rank
101	800	1
101	700	2
101	700	2
102	900	1
102	600	2
Key Difference: Unlike RANK(), DENSE_RANK() does not skip numbers after a tie.

LAG() – Fetches the previous row’s value
 
  
SELECT customer_id, purchase_amount,
       LAG(purchase_amount, 1, 0) OVER (PARTITION BY customer_id ORDER BY purchase_amount DESC) AS prev_purchase
FROM purchases;
Example Output:
customer_id	purchase_amount	prev_purchase
101	800	0
101	700	800
101	700	700
102	900	0
102	600	900
LEAD() – Fetches the next row’s value
 
  
SELECT customer_id, purchase_amount,
       LEAD(purchase_amount, 1, 0) OVER (PARTITION BY customer_id ORDER BY purchase_amount DESC) AS next_purchase
FROM purchases;
Example Output:
customer_id	purchase_amount	next_purchase
101	800	700
101	700	700
101	700	0
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

3. Recursive CTE (For Hierarchical Data)
 
  
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

5. PIVOT (Transposing Rows into Columns –   Server Example)
 
  
SELECT * FROM (
    SELECT customer_id, order_status, order_amount FROM orders
) src
PIVOT (
    SUM(order_amount) FOR order_status IN ([Completed], [Pending], [Cancelled])
) AS pivot_table;

6. STRING_AGG (Concatenating grouped values –   Server, Postgre )
 
  
SELECT customer_id, STRING_AGG(product_name, ', ') AS product_list
FROM orders
GROUP BY customer_id;

7. JSON Functions (Postgre , My  Example)
 
  
SELECT order_id, json_data->>'customer_name' AS customer_name FROM orders;
 
  
SELECT order_id, jsonb_array_elements(json_col) AS json_values FROM orders;

8. LATERAL JOIN (For querying array elements separately – Postgre ,   Server)
 
  
SELECT o.order_id, j.*
FROM orders o, LATERAL jsonb_array_elements(o.json_col) AS j;

9. PARTITION BY vs GROUP BY
GROUP BY (Aggregates at group level)
 
  
SELECT customer_id, SUM(order_amount) FROM orders GROUP BY customer_id;
PARTITION BY (Aggregates while keeping original rows)
 
  
SELECT customer_id, order_id, 
       SUM(order_amount) OVER (PARTITION BY customer_id) AS total_orders
FROM orders;


