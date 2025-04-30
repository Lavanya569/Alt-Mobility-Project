select * from payments;
select * from customer_orders;

/* 1. Order and Sales Analysis: 
o Analyze order status and sales data to provide insights into order 
fulfillment and revenue trends. Identify key metrics and trends related to 
order status and sales. 
To do this analysis we have to do it in 4 parts 
a. Order Status Distribution
b. Monthly Revenue Trend (Completed Payments)
c. Fulfillment Rate
d. Average Order Value (AOV) by Month
*/
-- a. Order Status Distribution
-- it gives idea about types of orders_status are present and  in each type how many orders are placed can be known.

SELECT 
    order_status, 
    COUNT(order_status) AS total_orders
FROM customer_orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- b. Monthly Revenue Trend (Completed Payments)
 SELECT 
    date_format(o.order_date,'%Y-%m') AS month,
    SUM(p.payment_amount) AS monthly_revenue
FROM customer_orders o
JOIN payments p ON o.order_id = p.order_id
WHERE p.payment_status = 'completed'
GROUP BY month
ORDER BY month;

-- c. Fulfillment Rate

    --  FR = 100 * orders(delivered,shipped) / total orders   (66.17%)

SELECT 
    ROUND(
        100.0 * SUM(CASE WHEN order_status IN ('shipped', 'delivered') THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS fulfillment_rate_percentage
FROM customer_orders; 

-- Average Order Value (AOV) by Month 
-- It shows how much, on average, customers spend per fulfilled order each month.

  SELECT 
    date_format(order_date,'%Y-%m') AS month,
    ROUND(AVG(order_amount), 2) AS avg_order_value
FROM customer_orders
WHERE order_status IN ('shipped', 'delivered')
GROUP BY month
ORDER BY month;

/* 2. Customer Analysis: 
o Explore customer ordering behavior to identify patterns such as repeat 
ordering, customer segmentation, and trends over time.
To do this analysis we have to do it in 3 parts 
a. Repeat Customers (Count of Repeat vs One-Time)
b. Monthly Active Customers
c. Customer Segmentation by Order Value
*/

/* a. Repeat Customers (Count of Repeat vs One-Time)
repeat customers -1097
one_time customers - 2930 */

SELECT 
    CASE 
        WHEN order_count > 1 THEN 'Repeat Customer'
        ELSE 'One-time Customer'
    END AS customer_type,
    COUNT(*) AS customer_count
FROM (
    SELECT customer_id, COUNT(*) AS order_count
    FROM customer_orders
    GROUP BY customer_id
) sub
GROUP BY customer_type;

-- b. Monthly Active Customers
SELECT 
    date_format( order_date,'%Y-%m') AS month,
    COUNT(DISTINCT customer_id) AS active_customers
FROM customer_orders
GROUP BY month
ORDER BY month;

/* c. Customer Segmentation by Order Value
from this  u will getto know each customer how many orders are placed for
 that how much amount spent and that customer belongs to which category */ 
SELECT 
    customer_id,
    COUNT(*) AS total_orders,
    SUM(order_amount) AS total_spent,
    CASE 
        WHEN SUM(order_amount) >= 1000 THEN 'High Value'
        WHEN SUM(order_amount) >= 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS segment
FROM customer_orders
GROUP BY customer_id;

/* 3. Payment Status Analysis: 
o Investigate payment status data to identify any potential issues or trends 
related to payment success and failure.
this analysis done in 3 parts 
a. Payment Status Distribution
b. Monthly Payment Failures
c. Failure Rate by Payment Method */

-- a. Payment Status Distribution
-- from this u will get to know how much percentage of  each category of payment_status are there
SELECT 
    payment_status,
    COUNT(*) AS total_payments,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM payments), 2) AS percentage
FROM payments
GROUP BY payment_status;


-- b. Monthly Payment Failures
SELECT 
    date_format(payment_date,'%y-%m') AS month,
    COUNT(*) AS failed_payments
FROM payments
WHERE payment_status = 'failed'
GROUP BY month
ORDER BY month;


-- c. Failure Rate by Payment Method
SELECT 
    payment_method,
    ROUND(
        100.0 * SUM(CASE WHEN payment_status = 'failed' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS failure_rate_percent
FROM payments
GROUP BY payment_method;


-- 4. Order Details Report

SELECT 
    o.order_id,
    o.customer_id,
    o.order_date,
    o.order_amount,
    o.order_status,
    p.payment_id,
    p.payment_date,
    p.payment_amount,
    p.payment_method,
    p.payment_status
FROM customer_orders o
LEFT JOIN payments p ON o.order_id = p.order_id
ORDER BY o.order_date DESC;






































































