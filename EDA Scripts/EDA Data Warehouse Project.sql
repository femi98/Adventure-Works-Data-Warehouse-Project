-- Perform Descriptive Statistics
 -- Find the total sales
 -- Find how many items are sold
 -- Find the average selling price
 -- Find the total number of orders
 -- Find the total number of products
 -- Find the total number of customers
 -- Find the total number of customers that has placed an order

select 'Total Sales' as measure_name, sum(sales_amount) as measure_value from gold.fact_sales
 union all 
select 'Total Quantity', sum(quantity) from gold.fact_sales
 union all 
select 'Average Price', avg(price) from gold.fact_sales
 union all 
select 'Total Orders', count(distinct order_num) from gold.fact_sales
 union all 
select 'Total Products', count(product_key) from gold.dim_products
 union all
select 'Total Customers', count(customer_key) from gold.dim_customers
 union all 
select 'Customers with Orders', count(distinct customer_key) from gold.dim_customers;


------------------------------------------------------------------------------------------------------------------------
-- Generate a report of total customers by Country
select country, count(customer_key) as total_customers 
 from gold.dim_customers
    group by country
 union all 
 select 'Total', count(customer_key) from gold.dim_customers

----------------------------------------------------------------------------------------------------------------------
-- Find the total customers by Gender
select gender, count(customer_key) as total_customers
 from gold.dim_customers
    group by gender

----------------------------------------------------------------------------------------------------------------------
-- Find total products by category
select category, count(product_key) as total_products
 from gold.dim_products
    group by category;

----------------------------------------------------------------------------------------------------------------------
-- Find average cost by category
select category, avg(cost) as average_cost
 from gold.dim_products
    group by category
    order by average_cost desc;

----------------------------------------------------------------------------------------------------------------------
-- What is the total revenue generated for each category
select category, sum(sales_amount) as total_revenue
 from gold.fact_sales f
 left join gold.dim_products p on p.product_key = f.product_key
    group by category
    order by total_revenue desc;
----------------------------------------------------------------------------------------------------------------------
-- What is the total revenue generated for each country
select country, sum(sales_amount) as total_revenue
 from gold.fact_sales f  
 left join gold.dim_customers c on c.customer_key = f.customer_key
    group by country
 union all 
select 'Total', sum(sales_amount) from gold.fact_sales
    order by total_revenue;
----------------------------------------------------------------------------------------------------------------------
-- What is the average/median age of customers by gender across Countries
select gender, avg(datediff(year, birthdate,getdate())) as average_age
 from gold.dim_customers
    where gender in ('Male', 'Female')
    group by gender;

----------------------------------------------------------------------------------------------------------------------
-- Find the top 5 customers in each country
with Top_Customers as (
    select c.customer_id, first_name, last_name, country,gender,
            sum(sales_amount) as total_revenue,
            row_number() over(partition by country  order by sum(sales_amount) desc) as Customer_Ranking
     from gold.fact_sales f
     left join  gold.dim_customers c on c.customer_key = f.customer_key
        group by c.customer_id, first_name, last_name,country, gender
)
select * from Top_Customers where Customer_Ranking <= 5 and country != 'n/a' order by total_revenue desc 

----------------------------------------------------------------------------------------------------------------------
-- Which 5 subcategory generate the highest revenue
select top 5 f.product_key, subcategory, sum(sales_amount) as total_revenue
 from gold.fact_sales f
  left join gold.dim_products p on p.product_key = f.product_key
   group by f.product_key, subcategory
   order by total_revenue desc


----------------------------------------------------------------------------------------------------------------------
-- Which subcategory generates the highest revenue annually
with Top_Product as (
    select  subcategory,
            year(order_date) as year,
            sum(sales_amount) as total_revenue,
            row_number() over(partition by year(order_date) order by sum(sales_amount) desc) as product_ranking
     from gold.fact_sales f
     left join  gold.dim_products p on p.product_key = f.product_key
         where year(order_date) is not null
         group by subcategory, year(order_date)
)
select year, subcategory, total_revenue  from Top_Product where product_ranking = 1 