-- CREATE DATABASE
-- CREATE DATABASE restaurant;
   
-- USE restaurant;

-- CREATING DATA SET

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),

  ('B', '2021-01-09');

Select *From members;
Select *From menu;
Select *From Sales;

-- Q1. Total amount spent by each customer?

SELECT s.customer_id, SUM(m.price) AS total_amount_spent
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- Q2. How many unique dates customer visited the restauraunt?

SELECT customer_id, COUNT(DISTINCT order_date) AS unique_visit_dates
FROM sales
GROUP BY customer_id;

-- Q3. What was the first item from the menu purchased by each customer?

SELECT s.customer_id, m.product_name
FROM sales s
JOIN menu m ON s.product_id = m.product_id
WHERE s.order_date = (SELECT MIN(order_date) FROM sales WHERE customer_id = s.customer_id);

-- Q4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT m.product_name, COUNT(s.product_id) AS total_purchases
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY total_purchases DESC
LIMIT 1;

-- Q5. Which item was the most popular for each customer?

SELECT s.customer_id, m.product_name, COUNT(s.product_id) AS purchase_count
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
HAVING purchase_count = (
    SELECT MAX(purchase_count) 
    FROM (
        SELECT COUNT(s2.product_id) AS purchase_count
        FROM sales s2
        WHERE s2.customer_id = s.customer_id
        GROUP BY s2.product_id
    ) AS subquery
);

-- Q6. Which item was purchased first by the customer after they became a member?

SELECT s.customer_id, m.product_name
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mem ON s.customer_id = mem.customer_id
WHERE s.order_date >= mem.join_date
AND s.order_date = (SELECT MIN(order_date) FROM sales WHERE customer_id = s.customer_id AND order_date >= mem.join_date);

-- Q7. Which item was purchased just before the customer became a member?

SELECT s.customer_id, m.product_name
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mem ON s.customer_id = mem.customer_id
WHERE s.order_date < mem.join_date
AND s.order_date = (SELECT MAX(order_date) FROM sales WHERE customer_id = s.customer_id AND order_date < mem.join_date);

-- Q8. What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id, COUNT(s.product_id) AS total_items, SUM(m.price) AS total_spent
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mem ON s.customer_id = mem.customer_id
WHERE s.order_date < mem.join_date
GROUP BY s.customer_id;

-- Q9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT s.customer_id, 
       SUM(CASE 
            WHEN m.product_name = 'sushi' THEN m.price * 20 
            ELSE m.price * 10 
           END) AS total_points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- Q10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January

SELECT s.customer_id, 
       SUM(
           CASE 
               WHEN s.order_date BETWEEN mem.join_date AND DATE_ADD(mem.join_date, INTERVAL 6 DAY) 
               THEN m.price * 20 
               WHEN m.product_name = 'sushi' 
               THEN m.price * 20 
               ELSE m.price * 10 
           END
       ) AS total_points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mem ON s.customer_id = mem.customer_id
WHERE s.order_date <= '2021-01-31'
GROUP BY s.customer_id;
