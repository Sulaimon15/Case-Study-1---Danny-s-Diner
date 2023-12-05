----question 1
SELECT s.customer_id, SUM(price) AS Total_amount_spent
FROM sales s
INNER JOIN menu  m
ON s.product_id= m.product_id
GROUP BY s.customer_id


---question 2
SELECT customer_id, COUNT(DISTINCT(order_date)) AS number_of_days
FROM sales
GROUP BY customer_id


---question 3 
SELECT customer_id, product_name 
FROM (
		SELECT s.customer_id, m.product_name,
		DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY order_date) AS first_purchase
		FROM sales s
		INNER JOIN menu m
		ON s.product_id = m.product_id) x
WHERE x.first_purchase = 1


-----question 4
SELECT customer_id, product_name, COUNT(*) AS number_of_purchase
FROM sales s
JOIN menu mu
ON s.product_id = mu.product_id
WHERE s.product_id = (
					SELECT TOP 1  product_id
					FROM sales s
					GROUP BY product_id
					ORDER BY  COUNT(*) DESC)
GROUP BY customer_id, product_name


----question 5
SELECT customer_id, product_name
FROM (
		SELECT customer_id, s.product_id, product_name, COUNT(*) AS  count_of_items, 
		RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(*) DESC)AS rnk
		FROM sales s
		JOIN menu mu
		ON s.product_id = mu.product_id
		GROUP BY customer_id, s.product_id, product_name) x
WHERE x.rnk = 1


----question 6
WITH first_purchase AS 
(
	SELECT s.customer_id, s.product_id, product_name, order_date, 
	RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date) first_purchase_after_becoming_member
	FROM sales s
	JOIN menu mu 
	ON s.product_id = mu.product_id
	JOIN members m
	ON s.customer_id = m.customer_id
	WHERE order_date > join_date )

SELECT customer_id, product_name
FROM first_purchase
WHERE first_purchase_after_becoming_member = 1



----question 7
WITH last_purchase AS
(
	SELECT s.customer_id, product_name, order_date, join_date,
	DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date DESC) AS last_purchase
	FROM sales s
	JOIN menu mu 
	ON s.product_id = mu.product_id
	JOIN members m
    ON s.customer_id = m.customer_id
	WHERE order_date < join_date)

SELECT customer_id, product_name
FROM last_purchase
WHERE last_purchase = 1


----question 8
SELECT s.customer_id, COUNT(*) AS total_items_bought, SUM(price) AS total_price
FROM sales s
JOIN menu mu
ON s.product_id = mu.product_id
JOIN members m
ON s.customer_id = m.customer_id
WHERE order_date < join_date
GROUP BY s.customer_id


--- question 9
SELECT customer_id,
	SUM(CASE 
			WHEN product_name <> 'sushi' THEN price * 10
			ELSE price  * 20
			END ) AS total_points
FROM sales s 
JOIN menu mu 
ON s.product_id = mu.product_id
GROUP BY customer_id



---- question 10
SELECT s.customer_id, 
	   SUM(CASE 
			    WHEN mu.product_id = 1 THEN (price * 20)
				WHEN mu.product_id <> 1 AND (order_date between m.join_date AND 
				DATEADD(DAY, 6, join_date)) THEN (price * 20)
				ELSE (price *10) END )
				AS points
FROM sales s
JOIN members m
ON s.customer_id = m.customer_id
JOIN menu mu
ON s.product_id = mu.product_id
WHERE s.order_date <= '2021-01-31'
GROUP BY s.customer_id




--- Bonus question
SELECT s.customer_id, order_date, mu.product_name, price, 
		CASE 
			 WHEN order_date < join_date THEN 'N'
	         WHEN order_date >= join_date THEN 'Y' 
			 ELSE 'N' END AS member
FROM sales s
LEFT JOIN members m
ON s.customer_id = m.customer_id
JOIN menu mu 
ON s.product_id = mu.product_id




--Bonus question
 WITH ranking AS
 (
 SELECT s.customer_id, order_date, product_name, price, 
		CASE 
			 WHEN order_date < join_date THEN 'N'
	         WHEN order_date >= join_date THEN 'Y' 
			 ELSE 'N' END AS member
FROM sales s
JOIN menu mu 
ON s.product_id = mu.product_id
LEFT JOIN members m
ON s.customer_id = m.customer_id)

SELECT *,
	CASE
		WHEN member = 'N' THEN null
		ELSE DENSE_RANK() OVER( PARTITION BY customer_id, member ORDER BY order_date)
		END AS ranking
FROM ranking
 
