--------------------------------------------------------------------------------------------------------------------------------
/* ============================================================
   PRODUCT MASTER DATA
   Retrieves product metadata including category and cost info.
   Category attributes come from erp_px_cat_g1v2.
   ============================================================ */
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
select
       row_number() over(order by p.prd_start_dt, p.prd_key)                as product_key,
       p.prd_id                                                             as product_id,
       p.prd_key                                                            as product_number,
       p.alternative_prd_key                                                as alt_product_number,
       p.cat_id                                                             as category_id,
       p2.cat                                                               as category,
       p2.subcat                                                            as subcategory,
       p.prd_nm                                                             as product_name,
       p2.maintenance                                                       as maintenance,
       p.prd_cost                                                           as cost,
       p.prd_line                                                           as product_line,
       p.prd_start_dt                                                       as start_date,
       p.prd_end_dt                                                         as end_date
 from   silver.crm_prd_info p
    left join silver.erp_px_cat_g1v2 p2                                     on p.cat_id = p2.id                 -- brings category & subcategory info
    where p.prd_end_dt is null;