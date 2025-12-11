/* ============================================================
   CUSTOMER MASTER DATA
   Extracts core customer attributes and resolves gender from:
     1. crm_cust_info (preferred if Male/Female)
     2. erp_cust_az12  (fallback if Male/Female)
     3. defaults to 'n/a' when neither source has valid gender
   ============================================================ */
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers                  AS
    select 
       row_number() over (order by c.cst_id)    as customer_key,
       c.cst_id                                 as customer_id,
       c.cst_key                                as customer_number,
       c.cst_firstname                          as first_name,
       c.cst_lastname                           as last_name,
       c3.cntry                                 as country,
       c.cst_marital_status                     as marital_status,

       /* Gender resolution logic */
       case
            when c.cst_gndr in ('Male','Female') then c.cst_gndr
            when c2.gen     in ('Male','Female') then c2.gen
            else 'n/a'
       end                                      as gender,
       c2.bdate                                 as birthdate,
       c.cst_create_date                        as create_date
 from  silver.crm_cust_info c
    left join silver.erp_cust_az12 c2           on c.cst_key = c2.cid                 -- join to fetch backup gender values
    left join silver.erp_loc_a101 c3            on c.cst_key = c3.cid                 -- (location data if needed)
  where c.cst_id is not null;                                                 -- ensures only valid customers
