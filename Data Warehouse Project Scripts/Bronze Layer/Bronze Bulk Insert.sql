create or alter procedure bronze.load_bronze as 
begin

    /*=====================================================================
        load bronze.crm_cust_info  
        - clears the existing table  
        - loads raw customer data from CRM source file  
        - skips header row (firstrow = 2)  
        - uses comma as field separator  
        - uses tablock for faster bulk loading  
    =====================================================================*/
    truncate table bronze.crm_cust_info;

    bulk insert bronze.crm_cust_info
    from 'C:\DW Project\source_crm\cust_info.csv'
    with (
        firstrow = 2,            -- skip header row
        fieldterminator = ',',   -- CSV format
        tablock                   -- improves performance for bulk loads
    );



    /*=====================================================================
        load bronze.crm_prd_info  
        - clears raw product table  
        - loads product master data from CRM export  
    =====================================================================*/
    truncate table bronze.crm_prd_info;

    bulk insert bronze.crm_prd_info
    from 'C:\DW Project\source_crm\prd_info.csv'
    with (
        firstrow = 2,
        fieldterminator = ',',
        tablock
    );



    /*=====================================================================
        load bronze.crm_sales_details  
        - clears CRM sales transaction data  
        - loads raw sales/order details from CRM  
    =====================================================================*/
    truncate table bronze.crm_sales_details;

    bulk insert bronze.crm_sales_details
    from 'C:\DW Project\source_crm\sales_details.csv'
    with (
        firstrow = 2,
        fieldterminator = ',',
        tablock
    );



    /*=====================================================================
        load bronze.erp_cust_az12  
        - clears ERP customer extension table  
        - loads customer master demographic data  
        - typically includes CID, birthdate, gender  
    =====================================================================*/
    truncate table bronze.erp_cust_az12;

    bulk insert bronze.erp_cust_az12
    from 'C:\DW Project\source_erp\CUST_AZ12.csv'
    with (
        firstrow = 2,
        fieldterminator = ',',
        tablock
    );



    /*=====================================================================
        load bronze.erp_loc_a101  
        - clears ERP customer location table  
        - loads country or address-related attributes  
        - part of ERP reference data  
    =====================================================================*/
    truncate table bronze.erp_loc_a101;

    bulk insert bronze.erp_loc_a101
    from 'C:\DW Project\source_erp\LOC_A101.csv'
    with (
        firstrow = 2,
        fieldterminator = ',',
        tablock
    );



    /*=====================================================================
        load bronze.erp_px_cat_g1v2  
        - clears ERP product category reference table  
        - loads product category and subcategory mappings  
        - used later for product enrichment  
    =====================================================================*/
    truncate table bronze.erp_px_cat_g1v2;

    bulk insert bronze.erp_px_cat_g1v2
    from 'C:\DW Project\source_erp\PX_CAT_G1V2.csv'
    with (
        firstrow = 2,
        fieldterminator = ',',
        tablock
    );


exec  bronze.load_bronze;