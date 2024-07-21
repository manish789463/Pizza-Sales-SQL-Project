USE Pizza_Hut
SELECT * FROM order_details
SELECT * FROM orders
SELECT * FROM pizza_types
SELECT * FROM pizzas

--   Basic Questions
--   Q1. Retrieve the total number of orders placed?
SELECT * FROM orders

SELECT COUNT(order_id) AS Total_Orders
FROM orders
		
-- Q2. Calculate the total revenue generated from pizza sales.


SELECT * FROM pizzas  
SELECT * FROM order_details

SELECT 
     ROUND(SUM(order_details.quantity * pizzas.price),2)
	 AS Total_Sales

FROM 
    order_details
       JOIN 
	   pizzas ON order_details.pizza_id = pizzas.pizza_id


-- Q3. Identify the highest-priced pizza.


SELECT * FROM pizzas 
SELECT * FROM pizza_types

SELECT TOP 1
     pizza_types.name AS Pizza_Name, pizzas.price AS Highest_Priced_Pizza
 FROM 
     pizzas
       JOIN 
	   pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC 


-- Q4. Identify the most common pizza size ordered.


SELECT * FROM order_details
SELECT * FROM pizzas

SELECT 
   pizzas.size, COUNT(order_details.pizza_id) 
   AS Total_Ordered
FROM order_details
      JOIN
	  pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY Total_Ordered DESC


-- Q5. List the top 5 most ordered pizza types along with their quantities.


SELECT * FROM order_details
SELECT * FROM pizza_types
SELECT * FROM pizzas

SELECT TOP 5 
   pizza_types.name, SUM(order_details.quantity) 
    AS Total_Quantity_Ordered 
FROM order_details
    JOIN 
	   pizzas ON order_details.pizza_id = pizzas.pizza_id
    JOIN 
	   pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name
ORDER BY Total_Quantity_Ordered DESC


-- Intermediate Questions

-- Q1. Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT * FROM order_details
SELECT * FROM pizza_types
SELECT * FROM pizzas

SELECT pizza_types.category, 
       SUM(order_details.quantity) 
	    AS Total_Quantity_Order
from 
    order_details
       JOIN 
	   pizzas ON order_details.pizza_id = pizzas.pizza_id
       JOIN 
	   pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category
ORDER BY Total_Quantity_Order DESC


-- Q2.  Determine the distribution of orders by hour of the day.
SELECT * FROM orders

SELECT DATEPART(HOUR,(time)) AS Hour,
COUNT(order_id) AS Order_Count 
FROM orders
GROUP BY DATEPART(HOUR,(time))
ORDER BY DATEPART(HOUR,(time))

-- Q3. Join relevant tables to find the category-wise distribution of pizzas.
SELECT * FROM pizza_types

SELECT category,
COUNT(name) AS No_of_Pizzas
FROM pizza_types
GROUP BY category

-- Q4. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT * FROM order_details
SELECT * FROM orders

SELECT AVG(Quantity) AS Pizza_Per_Day
 FROM
    (SELECT orders.date, SUM(order_details.quantity) AS Quantity
     FROM Orders
     JOIN 
	 order_details ON orders.order_id = order_details.order_id
GROUP BY orders.date) 
 AS Order_Quantity


-- Q5. Determine the top 3 most ordered pizza types based on revenue.
SELECT * FROM order_details
SELECT * FROM pizza_types
SELECT * FROM pizzas

SELECT TOP 3 pizza_types.name,
  SUM(order_details.quantity * pizzas.price)
  AS total_Revenue
FROM order_details
   JOIN 
     pizzas ON order_details.pizza_id = pizzas.pizza_id 
   JOIN
   pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name
ORDER BY total_Revenue DESC


--  ADvance Questions

-- Q1. Calculate the percentage contribution of each pizza type to total revenue.
SELECT * FROM order_details
SELECT * FROM pizza_types
SELECT * FROM pizzas

SELECT pizza_types.name,
      SUM(order_details.quantity * pizzas.price) AS Total_Sale,
      ROUND(SUM(order_details.quantity * pizzas.price) * 100/ (SELECT
             SUM(order_details.quantity * pizzas.price) 
        FROM order_details
            JOIN 
	       pizzas ON pizzas.pizza_id = order_details.pizza_id),2)  AS Total_Revenue
FROM pizza_types
   JOIN 
      pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
   JOIN 
      order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY Total_Revenue DESC


-- Q2.  Analyze the cumulative revenue generated over time Top 10.
SELECT * FROM order_details
SELECT * FROM orders
SELECT * FROM pizzas

SELECT TOP 10 date,
    SUM(Revenue) OVER(ORDER BY date) AS Cum_Revenue 
FROM
	(SELECT orders.date, ROUND(SUM(order_details.quantity * pizzas.price),2)
	  AS Revenue 
	FROM order_details
	    JOIN 
		   pizzas ON pizzas.pizza_id = order_details.pizza_id
	    JOIN 
		orders ON order_details.order_id = order_details.order_id
	 GROUP BY orders.date) AS Sale

-- Q3.	Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT category,name,Revenue,Rank_
FROM
(SELECT category,name,Revenue,
RANK() OVER(PARTITION BY category ORDER BY Revenue DESC) AS Rank_
FROM
(SELECT pizza_types.category, pizza_types.name, SUM(order_details.quantity  * pizzas.price) AS Revenue
FROM pizza_types
JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category,pizza_types.name) AS a) AS b
WHERE Rank_<=3
