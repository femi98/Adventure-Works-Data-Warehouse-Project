/* ============================================================
   SALES TRANSACTION DATA
   Combines sales details with customer & product dimensions.
   ============================================================ */
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
select
       s.sls_ord_num   as order_num,
       p.product_key,
       customer_key,
       s.sls_order_dt  as order_date,
       s.sls_ship_dt   as shipping_date,
       s.sls_due_dt    as due_date,
       s.sls_sales     as sales_amount,
       s.sls_quantity  as quantity,
       s.sls_price     as price
 from   silver.crm_sales_details s
    left join gold.dim_customers  c       on s.sls_cust_id = c.customer_id           -- customer dimension
    left join gold.dim_products   p       on p.alt_product_number = s.sls_prd_key;  -- product dimension
