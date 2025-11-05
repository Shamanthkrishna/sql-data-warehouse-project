/*
==========================================================================================================
  COMPLETE SETUP SCRIPT: DataWarehouse Initialization
==========================================================================================================

This script performs the following:
1. Drops and recreates the 'DataWarehouse' database.
2. Creates the schemas: bronze, silver, and gold.
3. Creates all bronze tables.
4. Creates and executes the stored procedure 'bronze.load_bronze' to load data from CSV files.

WARNING:
Running this script will permanently delete the existing 'DataWarehouse' database and all data within it.
Proceed only if you have backups or are initializing a new environment.

==========================================================================================================
*/

USE master;
GO

-- Drop and recreate database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO

/*
==========================================================================================================
  BRONZE TABLES CREATION
==========================================================================================================
*/

-- CRM Tables
IF OBJECT_ID ('bronze.crm_cust_info', 'U') IS NOT NULL DROP TABLE bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info (
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE
);

IF OBJECT_ID ('bronze.crm_prd_info', 'U') IS NOT NULL DROP TABLE bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info (
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE
);

IF OBJECT_ID ('bronze.crm_sales_details', 'U') IS NOT NULL DROP TABLE bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);

-- ERP Tables
IF OBJECT_ID ('bronze.erp_cust_az12', 'U') IS NOT NULL DROP TABLE bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12 (
    cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(50)
);

IF OBJECT_ID ('bronze.erp_loc_a101', 'U') IS NOT NULL DROP TABLE bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101 (
    cid NVARCHAR(50),
    cntry NVARCHAR(50)
);

IF OBJECT_ID ('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL DROP TABLE bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2 (
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50)
);
GO

/*
==========================================================================================================
  STORED PROCEDURE: bronze.load_bronze
==========================================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @bronze_layer_start_time DATETIME, @bronze_layer_end_time DATETIME;
    BEGIN TRY
        SET @bronze_layer_start_time = GETDATE();
        PRINT '===============================================================================================================';
        PRINT 'Loading the Bronze Layer';
        PRINT '===============================================================================================================';

        PRINT '---------------------------------------------------------------------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '---------------------------------------------------------------------------------------------------------------';

        -- CRM: cust_info
        SET @start_time = GETDATE();
        PRINT '>>> Truncating Table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>>> Inserting Data into: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM 'D:\SKB\Courses\Data Engineering 2.0\SQL\data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        SET @end_time = GETDATE();
        PRINT '>>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds';
        PRINT '-------------------';

        -- CRM: prd_info
        SET @start_time = GETDATE();
        PRINT '>>> Truncating Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>>> Inserting Data into: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'D:\SKB\Courses\Data Engineering 2.0\SQL\data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        SET @end_time = GETDATE();
        PRINT '>>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds';
        PRINT '-------------------';

        -- CRM: sales_details
        SET @start_time = GETDATE();
        PRINT '>>> Truncating Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>>> Inserting Data into: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM 'D:\SKB\Courses\Data Engineering 2.0\SQL\data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        SET @end_time = GETDATE();
        PRINT '>>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds';
        PRINT '-------------------';

        PRINT '---------------------------------------------------------------------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '---------------------------------------------------------------------------------------------------------------';

        -- ERP: cust_az12
        SET @start_time = GETDATE();
        PRINT '>>> Truncating Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>>> Inserting Data into: bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM 'D:\SKB\Courses\Data Engineering 2.0\SQL\data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        SET @end_time = GETDATE();
        PRINT '>>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds';
        PRINT '-------------------';

        -- ERP: loc_a101
        SET @start_time = GETDATE();
        PRINT '>>> Truncating Table: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>>> Inserting Data into: bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM 'D:\SKB\Courses\Data Engineering 2.0\SQL\data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        SET @end_time = GETDATE();
        PRINT '>>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds';
        PRINT '-------------------';

        -- ERP: px_cat_g1v2
        SET @start_time = GETDATE();
        PRINT '>>> Truncating Table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>>> Inserting Data into: bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'D:\SKB\Courses\Data Engineering 2.0\SQL\data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        SET @end_time = GETDATE();
        PRINT '>>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) as NVARCHAR) + ' seconds';
        PRINT '-------------------';

        SET @bronze_layer_end_time = GETDATE();
        PRINT '===============================================================================================================';
        PRINT '>>> Loading Bronze Layer Completed Successfully';
        PRINT '>>> Total Duration: ' + CAST(DATEDIFF(second, @bronze_layer_start_time, @bronze_layer_end_time) as NVARCHAR) + ' seconds';
        PRINT '===============================================================================================================';

    END TRY
    BEGIN CATCH
        PRINT '============================================================================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '============================================================================================';
    END CATCH
END;
GO

-- Execute the procedure
EXEC bronze.load_bronze;
GO
