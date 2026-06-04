use monday_coffee;
select * from sales;
select * from city;


-- Q1 How many people in each city are estimated to consume coffee, given that 25% of the population does?
select city_id , city_name ,population, Round((population * 0.25)/1000000,2) as coffee_consumers from city
order by population desc;

-- Q2 What is the total revenue generated from coffee sales across all cities in last qtr of 2023?
select sum(total) as total_revenue,city_name from sales
JOIN customers on customers.customer_id = sales.customer_id
JOIN city on city.city_id = customers.city_id
where quarter(sale_date) = 4 and year(sale_date) = 2023
group by city_name
order by total_revenue desc;

-- Q3 How many units of each coffee products have been sold?
select count(sales.product_id) as unit_sold ,products.product_name from sales
join products on sales.product_id = products.product_id group by products.product_name;

-- Q4 What is the average sales amount per customer in each city?
select (sum(sales.total)/count(distinct customers.customer_id)) as average_sales,city.city_name
from sales 
join customers on sales.customer_id = customers.customer_id
join city on customers.city_id = city.city_id
group by city.city_name
order by average_sales desc;

-- Q5 Provide a list of cities along with their populations and estimated coffee consumers?
select city.city_name,city.population,city.population * 0.25 as est_coffee_consumers, count(distinct customers.customer_id)
from city
join customers on customers.city_id = city.city_id
group by city.city_id;

-- Q6 What are the top 3 selling products in each city based on sales volume?
select * from
(select count(sales.sale_id) as total_orders,products.product_name,city.city_name,
row_number() over (partition by city.city_name order by count(sales.sale_id) desc)  rn
from sales
join products on sales.product_id = products.product_id
join customers on customers.customer_id = sales.customer_id
join city on city.city_id = customers.city_id
group by products.product_name , city.city_name
order by city.city_name,total_orders desc) as t1
where rn <= 3
;

-- Q7 How many unique customers are there in each city who have purchased coffee products ?
select city.city_name, count(distinct customers.customer_id) as unique_customers from city
join customers on city.city_id = customers.city_id
join sales on customers.customer_id = sales.customer_id
where sales.product_id between 1 and 14
group by city.city_name 
order by unique_customers desc;

-- Q8 Find each city and their average sales per customer and avg rent per customer?
select city.city_name, (sum(sales.total)/count(distinct customers.customer_id)) as average_sales_per_cust ,
(avg(city.estimated_rent)/ count(distinct customers.customer_id)) as avg_rent_per_cust 
from sales join customers on sales.customer_id = customers.customer_id
join city on city.city_id = customers.city_id
group by city.city_name
order by avg_rent_per_cust desc;

select city_name,average_sales_per_cust,(rent/no_of_cust) as avg_rent_per_cust from
(select city.city_name, (sum(sales.total)/count(distinct customers.customer_id)) as average_sales_per_cust ,
avg(city.estimated_rent) as rent,count(distinct customers.customer_id) as no_of_cust
from sales join customers on sales.customer_id = customers.customer_id
join city on city.city_id = customers.city_id
group by city.city_name) as t1
order by avg_rent_per_cust desc;


-- Q9 Sales growth rate: calculate the percentage growth in sales over different time period ( monthly)?

select * ,((total_sale - prev_sale)/prev_sale)*100 as perc_change from(
select *, LAG(total_sale) over ( partition by city_name order by year_date,month_year) prev_sale
from (
select  city.city_name,month(sales.sale_date) as month_year,year(sales.sale_date) as year_date,sum(sales.total) as total_sale
from sales
join customers on customers.customer_id = sales.customer_id
join city on customers.city_id = city.city_id
group by city.city_name,month_year,year_date
order by city.city_name,year_date,month_year) as t1) as t2;

-- Q10 Identify top 3 cities based on highest sales, return city name , total rent,total customers, estimated coffee customers?

select city.city_name, avg(city.estimated_rent) ,count(distinct customers.customer_id) as no_of_cust, population * 0.25 as est_coffee_cust,
sum(sales.total) as total_sale , ( avg(city.estimated_rent)/count(distinct customers.customer_id)) as rent_per_cust
from city join customers on city.city_id = customers.city_id
join sales on sales.customer_id = customers.customer_id
group by city.city_id
order by total_sale desc
limit 3;

-- FINAL RECOMMENDATIONS #
-- 1) DELHI - Highest Potential in Sales 
-- 2) Pune- Expected to have decent potential with the highest Profitability due to lower costs
-- 3) Chennai- Offers a balance of high potential and affordable rent