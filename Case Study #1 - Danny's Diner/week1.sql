-- Create a schema in PgAdmin4 and select it.
CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

-- Create Sales table and insert values in it (All of this is available in the website) 
CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
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
 
-- Create Menu table and insert values in it (All of this is available in the website) 
CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
-- Create Members table and insert values in it (All of this is available in the website) 
CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  

__________________________________________________________________


select * from members
select * from menu
select * from sales


-- 1. What is the total amount each customer spent at the restaurant?
select s.customer_id, sum(m.price) 
from sales s join menu m 
on s.product_id = m.product_id 
group by customer_id 
order by customer_id

-- 2. How many days has each customer visited the restaurant?
select customer_id, count(distinct order_date) 
from sales 
group by customer_id 
order by customer_id

-- 3. What was the first item from the menu purchased by each customer?
with PurchaseDate as(
	select s.customer_id, m.product_name, s.order_date, 
	dense_rank() over (partition by s.customer_id order by s.order_date) rank
	from sales s join menu m on s.product_id = m.product_id
	group by S.customer_id, M.product_name,S.order_date
)

select customer_id, product_name from PurchaseDate
where rank = 1

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select m.product_name, count(s.product_id) from 
sales s join menu m on s.product_id = m.product_id 
group by m.product_name 
limit 1

-- 5. Which item was the most popular for each customer?
WITH most_popular AS (
  SELECT s.customer_id, m.product_name, COUNT(m.product_id) AS order_count,
    DENSE_RANK() OVER(
      PARTITION BY s.customer_id 
      ORDER BY COUNT(s.customer_id) DESC) AS rank
  FROM menu m
  JOIN sales s
    ON m.product_id = s.product_id
  GROUP BY s.customer_id, m.product_name
)

SELECT 
  customer_id, 
  product_name, 
  order_count
FROM most_popular 
WHERE rank = 1;

-- 6. Which item was purchased first by the customer after they became a member?
with joining_date as (
	select mem.customer_id, s.product_id,
	row_number() over(partition by s.customer_id order by s.order_date) row_num
	from sales s join members mem
	on mem.customer_id = s.customer_id
	and s.order_date>mem.join_date
)

select j.customer_id, m.product_name 
from joining_date j join menu m 
on j.product_id = m.product_id 
where row_num=1

-- 7. Which item was purchased just before the customer became a member?
with joining_date as (
	select mem.customer_id, s.product_id, s.order_date,
	row_number() over(partition by s.customer_id order by s.order_date desc) row_num
	from members mem join sales s 
	on mem.customer_id = s.customer_id
	and mem.join_date>s.order_date
)

select j.customer_id, m.product_name 
from joining_date j join menu m 
on j.product_id = m.product_id
where row_num = 1

-- 8. What is the total items and amount spent for each member before they became a member?
with before_joining as (
	select s.customer_id, s.product_id, s.order_date, mem.join_date
	from sales s join members mem
	on s.customer_id = mem.customer_id
	and s.order_date<mem.join_date
)

select s.customer_id, count(m.product_id), sum(m.price) 
from before_joining s join menu m 
on s.product_id = m.product_id
group by s.customer_id
order by s.customer_id

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with points as (
	select m.product_id, case when m.product_name = 'sushi' then 20*m.price
	else 10*m.price
	end as updatedprice
	from menu m
)

select s.customer_id, sum(p.updatedprice) 
from sales s join points p 
on s.product_id = p.product_id
group by s.customer_id
order by s.customer_id

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH dates_cte AS (
  SELECT 
    customer_id, 
    join_date, 
    join_date + 6 AS valid_date, 
    DATE_TRUNC(
      'month', '2021-01-31'::DATE)
      + interval '1 month' 
      - interval '1 day' AS last_date
  FROM dannys_diner.members
)

SELECT 
  sales.customer_id, 
  SUM(CASE
    WHEN menu.product_name = 'sushi' THEN 2 * 10 * menu.price
    WHEN sales.order_date BETWEEN dates.join_date AND dates.valid_date THEN 2 * 10 * menu.price
    ELSE 10 * menu.price END) AS points
FROM dannys_diner.sales
JOIN dates_cte AS dates
  ON sales.customer_id = dates.customer_id
  AND sales.order_date <= dates.last_date
JOIN dannys_diner.menu
  ON sales.product_id = menu.product_id
GROUP BY sales.customer_id;

