-- Create a schema in PgAdmin4 and select it.
CREATE SCHEMA pizza_runner;
SET search_path = pizza_runner;

-- Create runners table and insert values in it (All of this is available in the website) 
DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

-- Create customer_orders table and insert values in it (All of this is available in the website) 
DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');

-- Create runner_orders table and insert values in it (All of this is available in the website) 
DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');

--Create pizza_names table and insert values in it (All of this is available in the website) 
DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);

INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');

--Create pizza_recipes table and insert values in it (All of this is available in the website) 
DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');

--Create pizza_toppings table and insert values in it (All of this is available in the website) 
DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  
--Data Cleaning for Customer Orders--
select * from customer_orders

drop table if exists c_orders_temp; 

create table c_orders_temp as 
select order_id, customer_id, pizza_id,
case when exclusions = '' or exclusions = 'null' then NULL
else exclusions end,
case when extras = '' or extras = 'null' then NULL
else extras end,
order_time
from customer_orders

select * from c_orders_temp
-----------------------------------

--Data Cleaning for Runner Orders--
select * from runner_orders

drop table if exists r_orders_temp;
create table r_orders_temp as
select order_id, runner_id, 
case when pickup_time = 'null' then NULL
else pickup_time end,
case when distance = 'null' then NULL
else distance end,
case when duration = 'null' then NULL
else duration end,
case when cancellation = 'null' or cancellation = '' then NULL
else cancellation end
from runner_orders

select * from r_orders_temp
-----------------------------------

select * from pizza_names
select * from pizza_recipes
select * from pizza_toppings


--Pizza Metrics
-- How many pizzas were ordered?
select count(pizza_id) Pizza_Orders from customer_orders

-- How many unique customer orders were made?
select count(distinct(order_id)) unique_orders from c_orders_temp

-- How many successful orders were delivered by each runner?
select runner_id, count(order_id) 
from r_orders_temp 
where cancellation is NULL 
group by runner_id

-- How many of each type of pizza was delivered?
select p.pizza_name, count(c.pizza_id) 
from c_orders_temp c join pizza_names p 
on c.pizza_id = p.pizza_id 
join r_orders_temp r
on c.order_id = r.order_id
where cancellation is NULL
group by p.pizza_name

-- How many Vegetarian and Meatlovers were ordered by each customer?
select c.customer_id, 
sum(case when p.pizza_name = 'Vegetarian' then 1 else 0 end) vegetarians,
sum(case when p.pizza_name = 'Meatlovers' then 1 else 0 end) meat_lovers
from c_orders_temp c join pizza_names p
on c.pizza_id = p.pizza_id
group by c.customer_id
order by c.customer_id

-- What was the maximum number of pizzas delivered in a single order?
select order_id, count(pizza_id) total_pizzas 
from c_orders_temp 
group by order_id 
order by total_pizzas desc
limit 1

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?	
select customer_id, 
sum(case when exclusions is not NULL or extras is not NULL then 1
else 0 end) changes,
sum(case when exclusions is NULL and extras is NULL then 1
else 0 end) no_changes
from c_orders_temp c join r_orders_temp r
on c.order_id = r.order_id
where r.distance is not NULL
group by customer_id
order by customer_id 

-- How many pizzas were delivered that had both exclusions and extras?
select count(pizza_id) pizza_count
from c_orders_temp c join r_orders_temp r
on c.order_id = r.order_id
where c.exclusions is not NULL and c.extras is not NULL and cancellation is NULL

-- What was the total volume of pizzas ordered for each hour of the day?
select extract(hour from order_time) hour_of_day, count(order_id)
from c_orders_temp
group by hour_of_day
order by hour_of_day

-- What was the volume of orders for each day of the week?
select * from c_orders_temp
select to_char(order_time, 'Day') hour_of_day, count(order_id)
from c_orders_temp
group by hour_of_day
order by hour_of_day