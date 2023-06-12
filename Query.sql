--Monthly active user
WITH avg_MAU as ( 
SELECT Year, floor(AVG(Jumlah_customer)) AS Average_MAU
FROM (
	SELECT 
		date_part('year', od.order_purchase_timestamp) AS year,
		date_part('month', od.order_purchase_timestamp) AS month,
		COUNT(DISTINCT cd.customer_unique_id) AS Jumlah_customer
	FROM orders_dataset AS od
	JOIN customers_dataset AS cd
		ON cd.customer_id = od.customer_id
	GROUP BY 1, 2
	) as sub
GROUP BY 1
ORDER BY 1
),


--New Customer per year
New_cust as (
Select 
	date_part('year', first_purchase) as year,
	count(1) as newcust 
from (
	select 
	cd.customer_unique_id,
	min(od.order_purchase_timestamp) as first_purchase
	from orders_dataset as od
	join customers_dataset as cd on cd.customer_id = od.customer_id
	group by 1
) subq
group by 1 
order by 1
),

--Jumlah customer repeat order per tahun
Repeat_order as (
Select 
	year,
	count(customer_unique_id) as Langganan
From (
	select 
		date_part('year', od.order_purchase_timestamp) as year,
		cd.customer_unique_id,
		count(od.order_id) as total_order
	from orders_dataset as od
	join customers_dataset as cd
		on od.customer_id = cd.customer_id
	group by 1, 2
	having count(2) > 1
		) as subq
group by 1
order by 1
),

-- Menampilkan rata-rata jumlah order pertahun
Average_order as (
Select year, round(avg(freq),3) as average
from (
		select 
			date_part('year', od.order_purchase_timestamp) as year,
			cd.customer_unique_id,
			count(order_id) as freq
		from orders_dataset as od
		join customers_dataset as cd
		on cd.customer_id = od.customer_id
	group by 1, 2
	) as subq
group by 1
order by 1
)

SELECT
	mau.year AS year,
	Average_MAU,
	newcust,
	Langganan,
	average
FROM
	avg_mau AS mau
	JOIN New_cust AS nc
		ON mau.year = nc.year
	JOIN Repeat_order AS ro
		ON nc.year = ro.year
	JOIN Average_order AS ao
		ON ro.year = ao.year
GROUP BY 1, 2, 3, 4, 5
ORDER BY 1
;