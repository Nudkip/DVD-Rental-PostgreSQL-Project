--1)-- find out the ten 10 film that havent rent out for the longest time for each store

SELECT I.store_id, I.film_id, COUNT(I.inventory_id), MAX(R.return_date) AS returning_date, P.amount,
       RANK() OVER (PARTITION BY I.store_id ORDER BY MAX(R.return_date)) AS rental_rank
FROM inventory I
JOIN rental R ON I.inventory_id = R.inventory_id
JOIN payment P ON P.rental_id = R.rental_id
LEFT OUTER JOIN
  (SELECT rental_id FROM rental WHERE return_date IS NULL) AS newtable ON newtable.rental_id = R.rental_id
GROUP BY I.store_id, I.film_id, P.amount
ORDER BY I.store_id, MAX(R.return_date), I.film_id;

--2)-- giving 30% off on the 5 film with the longest time staying in the store and 20% off on other 5 film for each store
SELECT *,
    CASE
        WHEN rental_rank <= 5 THEN amount * 0.7
        WHEN rental_rank > 5 AND rental_rank < 10 THEN amount * 0.8
    END AS adjust_amount
FROM (
    SELECT I.store_id, I.film_id, COUNT(I.inventory_id), MAX(R.return_date) AS returning_date, P.amount,
        RANK() OVER (PARTITION BY I.store_id ORDER BY MAX(R.return_date)) AS rental_rank
    FROM inventory I
    JOIN rental R ON I.inventory_id = R.inventory_id
    JOIN payment P ON P.rental_id = R.rental_id
    LEFT OUTER JOIN (
        SELECT rental_id FROM rental WHERE return_date IS NULL
    ) AS newtable ON newtable.rental_id = R.rental_id
    GROUP BY I.store_id, I.film_id, P.amount
) AS subquery
ORDER BY store_id, returning_date, film_id;


--3)-- FIND the 10 longest film that start with A
SELECT * FROM film WHERE title LIKE 'A%' ORDER BY length DESC LIMIT 10;

--4)--Finding customer monthly spending
SELECT DISTINCT customer_id, 
	SUM(amount) OVER (PARTITION BY EXTRACT(MONTH FROM payment_date), customer_id) AS total_monthly_spend, 
	AVG(amount) OVER (PARTITION BY EXTRACT(MONTH FROM payment_date), customer_id) AS avg_monthly_spend, 
	EXTRACT(month FROM payment_date) AS month
FROM payment
ORDER BY customer_id asc, month asc;

--5)-- Finding the highest rating of the year
SELECT DISTINCT release_year,
MAX(rental_rate) OVER (PARTITION BY release_year) AS Highest_rating_of_the_year
FROM film

--6) -- Finding the highest rating of the year about different length of movie	

SELECT DISTINCT release_year,
    MAX(CASE WHEN length <= 60 THEN rental_rate END) AS Highest_rating_of_the_year_length_60,
    MAX(CASE WHEN length > 60 AND length <= 120 THEN rental_rate END) AS Highest_rating_of_the_year_length_60_120,
    MAX(CASE WHEN length > 120 THEN rental_rate END) AS Highest_rating_of_the_year_length_120
FROM film
GROUP BY release_year;

--7) -- Finding the performance of different employee

SELECT CONCAT(staff.first_name,' ', staff.last_name) , count(rental.rental_id) as Customer_Count  
FROM staff JOIN rental 
ON staff.staff_id = rental.staff_id 
GROUP BY staff.staff_id ORDER BY staff.staff_id;

--8)-- Finding the country of the customer  

SELECT country.country, COUNT(cust.customer_id) AS Customer_Country
FROM customer cust
LEFT JOIN address a ON a.address_id = cust.address_id
LEFT JOIN city c ON a.city_id = c.city_id 
LEFT JOIN country ON c.country_id = country.country_id
GROUP BY country.country
ORDER BY Customer_Country DESC;	
	
--9)-- Finding the country of the store
SELECT country.country, COUNT(store.store_id) AS Store_belonged_Country
FROM store
LEFT JOIN address a ON a.address_id = store.address_id
LEFT JOIN city c ON a.city_id = c.city_id 
LEFT JOIN country ON c.country_id = country.country_id
GROUP BY country.country
ORDER BY Store_belonged_Country DESC;

--10)-- Finding the daily amount of the store from different country
SELECT country.country, DATE(payment_date) as payment_date, SUM(p.amount) AS total_amount_of_each_day
FROM payment p 
LEFT JOIN customer cust ON p.customer_id = cust.customer_id
LEFT JOIN address a ON a.address_id = cust.address_id
LEFT JOIN city c ON a.city_id = c.city_id 
LEFT JOIN country ON c.country_id = country.country_id
GROUP BY country.country, DATE(payment_date)
ORDER BY country DESC;