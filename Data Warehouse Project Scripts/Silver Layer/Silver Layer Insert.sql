create or alter procedure silver.load_silver as 
begin

    /*=======================================================================
        load into silver.crm_prd_info
        - cleans and standardizes product attributes
        - derives category id and alternative product key
        - normalizes product line descriptions
        - computes end dates using lead() window function
    =======================================================================*/

    truncate table silver.crm_prd_info;

    insert into silver.crm_prd_info (
          prd_id,
          prd_key,
          alternative_prd_key,
          cat_id,
          prd_nm,
          prd_cost,
          prd_line,
          prd_start_dt,
          prd_end_dt
    )
    select
          prd_id,
          prd_key,

          -- extract characters after position 6 as alternative key
          substring(prd_key, 7, len(prd_key)) as alternative_prd_key,

          -- derive category id from prefix and replace '-' with '_'
          replace(substring(prd_key, 1, 5), '-', '_') as cat_id,

          prd_nm,

          -- replace null cost with 0
          isnull(prd_cost, 0) as prd_cost,

          -- standardize product line codes
          case
              when upper(trim(prd_line)) = 'M' then 'Mountain'
              when upper(trim(prd_line)) = 'R' then 'Road'
              when upper(trim(prd_line)) = 'S' then 'Other Sales'
              when upper(trim(prd_line)) = 'T' then 'Touring'
              else 'n/a'
          end as prd_line,

          -- force date type
          cast(prd_start_dt as date) as prd_start_date,

          -- compute end date as the day before next start date
          cast(
              lead(prd_start_dt - 1) over (
                  partition by prd_key
                  order by prd_start_dt
              ) as date
          ) as prd_end_dt
    from DataWarehouse.bronze.crm_prd_info;


    /*=======================================================================
        load into silver.crm_cust_info
        - trims names
        - normalizes marital status and gender
        - preserves create date
    =======================================================================*/

    truncate table silver.crm_cust_info;

    insert into silver.crm_cust_info (
          cst_id,
          cst_key,
          cst_firstname,
          cst_lastname,
          cst_marital_status,
          cst_gndr,
          cst_create_date
    )
    select
          cst_id,
          cst_key,

          -- remove leading/trailing spaces
          trim(cst_firstname) as cst_firstname,
          trim(cst_lastname) as cst_lastname,

          -- standardize marital status
          case
              when upper(trim(cst_marital_status)) = 'S' then 'Single'
              when upper(trim(cst_marital_status)) = 'M' then 'Married'
              else 'n/a'
          end as cst_marital_status,

          -- standardize gender
          case
              when upper(trim(cst_gndr)) = 'M' then 'Male'
              when upper(trim(cst_gndr)) = 'F' then 'Female'
              else 'n/a'
          end as cst_gndr,

          cst_create_date
    from bronze.crm_cust_info;


    /*=======================================================================
        load into silver.crm_sales_details
        - validates integer-based date fields
        - recalculates sales amount if inconsistent
        - recalculates price when invalid or missing
    =======================================================================*/

    truncate table silver.crm_sales_details;

    insert into silver.crm_sales_details (
          sls_ord_num,
          sls_prd_key,
          sls_cust_id,
          sls_order_dt,
          sls_ship_dt,
          sls_due_dt,
          sls_sales,
          sls_quantity,
          sls_price
    )
    select
          sls_ord_num,
          sls_prd_key,
          sls_cust_id,

          -- convert YYYYMMDD integer to date or null if invalid
          case
              when sls_order_dt <= 0 or len(sls_order_dt) != 8 then null
              else cast(cast(sls_order_dt as varchar) as date)
          end as sls_order_dt,

          case
              when sls_ship_dt <= 0 or len(sls_ship_dt) != 8 then null
              else cast(cast(sls_ship_dt as varchar) as date)
          end as sls_ship_dt,

          case
              when sls_due_dt <= 0 or len(sls_due_dt) != 8 then null
              else cast(cast(sls_due_dt as varchar) as date)
          end as sls_due_dt,

          -- enforce consistent sales = abs(quantity) * abs(price)
          case
              when sls_sales is null
                   or sls_sales <= 0
                   or sls_sales != abs(sls_quantity) * abs(sls_price)
              then abs(sls_quantity) * abs(sls_price)
              else sls_sales
          end as sls_sales,

          sls_quantity,

          -- compute price if null/invalid
          case
              when sls_price is null or sls_price <= 0
              then abs(sls_sales) / nullif(sls_quantity, 0)
              else sls_price
          end as sls_price
    from DataWarehouse.bronze.crm_sales_details;


    /*=======================================================================
        load into silver.erp_cust_az12
        - normalizes cid by removing NAS prefix
        - removes invalid future birthdates
        - standardizes gender values
    =======================================================================*/

    truncate table silver.erp_cust_az12;

    insert into silver.erp_cust_az12 (cid, bdate, gen)
    select
          -- remove 'NAS' prefix if present
          case
              when cid like 'NAS%' then substring(cid, 4, len(cid))
              else cid
          end as cid,

          -- replace future birthdates with null
          case
              when bdate > getdate() then null
              else bdate
          end as bdate,

          -- normalize gender values
          case
              when upper(trim(gen)) in ('M', 'MALE') then 'Male'
              when upper(trim(gen)) in ('F', 'FEMALE') then 'Female'
              else 'n/a'
          end as gen
    from bronze.erp_cust_az12;


    /*=======================================================================
        load into silver.erp_loc_a101
        - removes hyphens from cid
        - standardizes country names
    =======================================================================*/

    truncate table silver.erp_loc_a101;

    insert into silver.erp_loc_a101 (cid, cntry)
    select
          -- normalize cid
          trim(replace(cid, '-', '')) as cid,

          -- standardize country values
          case
              when upper(trim(cntry)) in ('DE', 'GERMANY') then 'Germany'
              when upper(trim(cntry)) in ('US', 'USA', 'UNITED STATES') then 'United States'
              when cntry is null or trim(cntry) = '' then 'n/a'
              else trim(cntry)
          end as cntry
    from bronze.erp_loc_a101;


    /*=======================================================================
        load into silver.erp_px_cat_g1v2
        - direct load from bronze without transformation
    =======================================================================*/

    truncate table silver.erp_px_cat_g1v2;

    insert into silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
    select *
    from bronze.erp_px_cat_g1v2;

end

exec silver.load_silver