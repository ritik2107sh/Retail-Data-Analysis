create database Retail_case_study;
use Retail_case_study;
select * from CUSTOMER;
select * from ORDERS;
select * from ORDERPAYMENTS;
select * from ORDERREVIEW_RATINGS;
select * from RETAIL_ANALYSIS.PUBLIC.PRODUCTSINFO;
select * from STORE_INFO;


SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
Describe table ORDERREVIEW_RATINGS
WHERE TABLE_NAME = 'CUSTOMER';

Describe table CUSTOMER;
Describe table ORDERS;
Describe table ORDERPAYMENTS;
Describe table PRODUCTSINFO;
Describe table STORE_INFO;;


---------------------------------------EXPLORATORY DATA ANALYSIS ON CUSTOMER TABLE----------------------------------------------------------------------

SELECT * FROM CUSTOMER;


SELECT count(CUSTID) FROM CUSTOMER 
--TOTAL CUSTOMER COUNT - 99441

SELECT COUNT(DISTINCT CUSTOMER_CITY) FROM CUSTOMER
--SO THERE ARE 4119 DISTINCT CITIES 

SELECT Gender, COUNT(*) AS count FROM customer GROUP BY Gender;
--29979 MALE
--69462 FRMALE

SELECT DISTINCT CUSTOMER_STATE FROM CUSTOMER
--SO THERE ARE 20 DISTINCT STATES IN DATASET

-- Top cities by number of customers
SELECT customer_city, COUNT(*) AS count FROM customer GROUP BY customer_city ORDER BY count DESC LIMIT 5;

-- Top states by number of customers
SELECT customer_state, COUNT(*) AS count FROM customer GROUP BY customer_state ORDER BY count DESC LIMIT 5;

SELECT COUNT(DISTINCT GENDER) FROM CUSTOMER
--TWO GENDER ONLY - M/F

SELECT GENDER , COUNT(GENDER) AS GENDER_COUNT FROM CUSTOMER GROUP BY GENDER ORDER BY COUNT(GENDER) DESC
--SO THERE ARE MORE FEMALE THEN MALE AS THE COUNT OF FEMALE IS MORE THAN DOUBLE THE MALE


---------------------------------------EXPLORATORY DATA ANALYSIS ON ORDERS TABLE--------------------------------------

--FORMATTING THE BILL_DATE_TIMESTAMP COLUMN IN A CORRECT FORMAT
UPDATE ORDERS
SET BILL_DATE_TIMESTAMP = CASE
    WHEN BILL_DATE_TIMESTAMP LIKE '%/%' THEN TO_TIMESTAMP(BILL_DATE_TIMESTAMP, 'MM/DD/YYYY HH24:MI')
    WHEN BILL_DATE_TIMESTAMP LIKE '%-%' THEN TO_TIMESTAMP(BILL_DATE_TIMESTAMP, 'MM-DD-YYYY HH24:MI')
    ELSE BILL_DATE_TIMESTAMP
END;

SELECT * FROM ORDERS

SELECT COUNT(ORDER_ID) FROM ORDERS
--112650 TOTAL ORDER_ID
SELECT COUNT(DISTINCT ORDER_ID) FROM ORDERS
--98666 DISTINCT ORDERS ID
-----------> THERE ARE 13984 DUPLICATE ORDER_ID


-- Step 1: Identify Duplicate Order IDs
SELECT order_id, COUNT(*)
FROM Orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Step 2: Retrieve Details of Duplicate Orders
SELECT o.*, p.payment_type, p.payment_value
FROM Orders o
JOIN (
    SELECT order_id
    FROM Orders
    GROUP BY order_id
    HAVING COUNT(*) > 1
) dup ON o.order_id = dup.order_id
JOIN ORDERPAYMENTS p ON o.order_id = p.order_id
ORDER BY o.order_id;

WITH CTE AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY (order_id,customer_id,product_id) ORDER BY order_id) AS rn
    FROM Orders
)
select * from cte where rn >1

SELECT o.*, p.payment_value
FROM Orders o
JOIN ORDERPAYMENTS p ON o.order_id = p.order_id
WHERE o.order_id IN (
    SELECT o_sum.order_id
    FROM (
        SELECT order_id, SUM(Total_Amount) AS total_amount_sum
        FROM Orders
        GROUP BY order_id
    ) o_sum
    JOIN ORDERPAYMENTS p ON o_sum.order_id = p.order_id
    WHERE o_sum.total_amount_sum <> p.payment_value
);


--1. Check for NULL Values
-- Count NULL values for each column
SELECT
    'Customer_id' AS column_name,
    COUNT(*) AS null_count
FROM
    Orders
WHERE
    Customer_id IS NULL
UNION ALL
SELECT
    'order_id' AS column_name,
    COUNT(*) AS null_count
FROM
    Orders
WHERE
    order_id IS NULL
UNION ALL
SELECT
    'product_id' AS column_name,
    COUNT(*) AS null_count
FROM
    Orders
WHERE
    product_id IS NULL
UNION ALL
SELECT
    'Channel' AS column_name,
    COUNT(*) AS null_count
FROM
    Orders
WHERE
    Channel IS NULL
UNION ALL
SELECT
    'Delivered_StoreID' AS column_name,
    COUNT(*) AS null_count
FROM
    Orders
WHERE
    Delivered_StoreID IS NULL
UNION ALL
SELECT
    'Bill_date_timestamp' AS column_name,
    COUNT(*) AS null_count
FROM
    Orders
WHERE
    Bill_date_timestamp IS NULL
UNION ALL
SELECT
    'Quantity' AS column_name,
    COUNT(*) AS null_count
FROM
    Orders
WHERE
    Quantity IS NULL
UNION ALL
SELECT
    'Cost_Per_Unit' AS column_name,
    COUNT(*) AS null_count
FROM
    Orders
WHERE
    Cost_Per_Unit IS NULL
UNION ALL
SELECT
    'MRP' AS column_name,
    COUNT(*) AS null_count
FROM
    Orders
WHERE
    MRP IS NULL
UNION ALL
SELECT
    'Discount' AS column_name,
    COUNT(*) AS null_count
FROM
    Orders
WHERE
    Discount IS NULL
UNION ALL
SELECT
    'Total_Amount' AS column_name,
    COUNT(*) AS null_count
FROM
    Orders
WHERE
    Total_Amount IS NULL;
--NO NULL VALUE IN ANY COLUMN



-----------------------------------------------------------QUANTITY COLUMN---------------------------------------------------
with cte1 as (
SELECT
    CASE WHEN (quantity * MRP) - (quantity * Discount) = TOTAL_AMOUNT
         THEN 'CORRECT'
         ELSE 'INCORRECT'
    END AS checkk
FROM orders)
select * from cte1 where checkk ='INCORRECT' ;
-- SO THE TOTAL_AMOUNT IN COLUMN IS CORRECT AS PER MRP , DISCOUNT AND QUANTITY COLUMN

select count(*) from orders where quantity > 2
--4181 records WHERE QUANTITY IS MORE THAN 2

--------------------------------------------------ORDER AND ORDERPAYMENT TABLE ANALYSIS--------------------------------------------------------------------
WITH CTE2 AS (
SELECT
      CASE WHEN (1 * MRP) - (1 * Discount) = PAYMENT_VALUE
         THEN 'CORRECT'
         ELSE 'INCORRECT'
    END AS checkk
FROM ORDERS AS A
INNER JOIN ORDERPAYMENTS AS P
ON A.ORDER_ID = P.ORDER_ID)
SELECT CHECKK , COUNT(CHECKK) FROM CTE2 GROUP BY CHECKK
--WHEN I AM TAKING THE COMMON RECORDS FROM BOTH TABLE AND TRY TO DO ANALYSIS AS 1 * MRP - 1 * DISCOUNT = TOTAL_AMOUNT WHICH IS ACTUALLY TRUE BUT WHEN I AM COMAPRING THE TOTAL AMOUNT WITH PAYMENT_VALUE THEN 86006 ORDERS ARE ACUTALLY FOLLWING THE ABOVE BUT FOR 31595 RECORDS WE ARE NOT JAVING ABOVE VALUES EQUAL


WITH CTE3 AS (
SELECT
      CASE WHEN (QUANTITY * MRP) - (QUANTITY * Discount) =  PAYMENT_VALUE
         THEN 'CORRECT'
         ELSE 'INCORRECT'
    END AS checkk
FROM ORDERS AS A
INNER JOIN ORDERPAYMENTS AS P
ON A.ORDER_ID = P.ORDER_ID)
SELECT CHECKK , COUNT(CHECKK) FROM CTE3 GROUP BY CHECKK

--WHEN I AM TAKING THE COMMON RECORDS FROM BOTH TABLE AND TRY TO DO ANALYSIS AS QUNATITY * MRP - QUANTITY * DISCOUNT = TOTAL_AMOUNT WHICH IS ACTUALLY TRUE BUT WHEN I AM COMAPRING THE TOTAL AMOUNT WITH PAYMENT_VALUE THEN 92898 ORDERS ARE ACUTALLY FOLLWING THE ABOVE BUT FOR 24703 RECORDS WE ARE NOT JAVING ABOVE VALUES EQUAL


-- Count duplicate order_id entries
SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM
    Orders
GROUP BY
    order_id
HAVING
    COUNT(*) > 1;
--9803 duplicate orders ID


-- Check for orders with invalid Customer_id 
SELECT
    o.order_id,
    o.Customer_id
FROM
    Orders o
LEFT JOIN
    Customer c ON o.Customer_id = c.Custid
WHERE
    c.Custid IS NULL;
-- NO INVALID CUSTOMER_ID IN ORDER TABLE

-- Check for negative quantities (assuming Quantity should not be negative)
SELECT
    order_id,
    Quantity
FROM
    Orders
WHERE
    Quantity < 0;

-- Check for unique Channel values
SELECT
    Channel,
    COUNT(*) AS channel_count
FROM
    Orders
GROUP BY
    Channel
HAVING
    COUNT(*) > 1;

--MIN DATE AND MAX DATE 
select min(bill_date_timestamp),max(bill_date_timestamp) from orders
-- DATA AVAILABILITY(Date Range:) ---> 2020-02-02 TO 2023-09-18

SELECT count(DISTINCT CUSTOMER_ID ) FROM ORDERS;
--TOTAL DISTINCT CUSTOMER IN ORDERS TABLE ARE 98575

SELECT count(DISTINCT CUSTID ) FROM CUSTOMER;
--SO TOTAL CUSTOMER IN CUSTOMER TABLE ARE 99441

--SO THERE ARE 866 CUSTOMER IN CUSTOMER TABLE THAT ARE NOT IN ORDER TABLE

SELECT count(DISTINCT PRODUCT_ID ) FROM ORDERS;
-- 32951 DISTINCT PRODUCT ID IN ORDER TABLE


select product_id, count(product_id) from orders group by product_id order by count( product_id) desc
SELECT DISTINCT CHANNEL FROM ORDERS
--THERE ARE 3 CHANNEL 

SELECT COUNT(DISTINCT DELIVERED_STOREID) AS STORES_COUNT FROM ORDERS
--THERE ARE 37 DELIVERED 

SELECT DISTINCT YEAR(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP)))  AS YEARS FROM ORDERS
-- SO THE DATA IS OF 4 YEARS

SELECT SUM(QUANTITY) AS TOTAL_QNT FROM ORDERS
-- SO TOTAL QUANTITY PRODUCT SOLD IS 134936

SELECT count(DISTINCT ORDER_ID ) FROM ORDERS;
-- 98666 DISTINCT ORDER ID IN ORDERS TABLE


SELECT SUM(DISCOUNT) AS TOTAL_DISCOUNT FROM ORDERS
--TOTAL DISCOUNT -  552442

--DESCRIPTIVE ANALYSIS
SELECT
    MIN(Quantity) AS min_quantity,
    MAX(Quantity) AS max_quantity,
    AVG(Quantity) AS avg_quantity,
    MIN(Cost_Per_Unit) AS min_cost_per_unit,
    MAX(Cost_Per_Unit) AS max_cost_per_unit,
    AVG(Cost_Per_Unit) AS avg_cost_per_unit,
    MIN(MRP) AS min_mrp,
    MAX(MRP) AS max_mrp,
    AVG(MRP) AS avg_mrp,
    MIN(Discount) AS min_discount,
    MAX(Discount) AS max_discount,
    AVG(Discount) AS avg_discount,
    MIN(Total_Amount) AS min_total_amount,
    MAX(Total_Amount) AS max_total_amount,
    AVG(Total_Amount) AS avg_total_amount
FROM
    Orders;


-- Count of orders by channel
SELECT
    Channel,
    COUNT(*) AS order_count,
    AVG(Total_Amount) AS avg_total_amount
FROM
    Orders
GROUP BY
    Channel;

-- Correlation analysis
SELECT
    CORR(Quantity, Total_Amount) AS correlation_quantity_total_amount,
    CORR(Cost_Per_Unit, Total_Amount) AS correlation_cost_per_unit_total_amount,
    CORR(MRP, Total_Amount) AS correlation_mrp_total_amount,
    CORR(Discount, Total_Amount) AS correlation_discount_total_amount
FROM
    Orders;



SELECT * 
FROM ORDERPAYMENTS AS P
LEFT JOIN ORDERS AS O
ON P.ORDER_ID = O.ORDER_ID
WHERE O.ORDER_ID IS NULL;

SELECT * 
FROM ORDERS AS O
LEFT JOIN ORDERPAYMENTS AS P
ON O.ORDER_ID = P.ORDER_ID


--------------------------------------------------------EDA ON PRODUCT INFO TABLE -------------------------------------------------------------------------

SELECT * FROM RETAIL_ANALYSIS.PUBLIC.PRODUCTSINFO WHERE CATEGORY IS NULL


--SUMMARY STATISTICS AND DATA DISTRIBUTION 
SELECT
    MIN(product_name_lenght) AS min_name_length,
    MAX(product_name_lenght) AS max_name_length,
    AVG(product_name_lenght) AS avg_name_length,
    MIN(product_description_lenght) AS min_desc_length,
    MAX(product_description_lenght) AS max_desc_length,
    AVG(product_description_lenght) AS avg_desc_length,
    MIN(product_photos_qty) AS min_photos_qty,
    MAX(product_photos_qty) AS max_photos_qty,
    AVG(product_photos_qty) AS avg_photos_qty,
    MIN(product_weight_g) AS min_weight_g,
    MAX(product_weight_g) AS max_weight_g,
    AVG(product_weight_g) AS avg_weight_g,
    MIN(product_length_cm) AS min_length_cm,
    MAX(product_length_cm) AS max_length_cm,
    AVG(product_length_cm) AS avg_length_cm,
    MIN(product_height_cm) AS min_height_cm,
    MAX(product_height_cm) AS max_height_cm,
    AVG(product_height_cm) AS avg_height_cm,
    MIN(product_width_cm) AS min_width_cm,
    MAX(product_width_cm) AS max_width_cm,
    AVG(product_width_cm) AS avg_width_cm
FROM
    RETAIL_ANALYSIS.PUBLIC.PRODUCTSINFO;

-- Category distribution
SELECT
    Category,
    COUNT(*) AS num_products
FROM
    RETAIL_ANALYSIS.PUBLIC.PRODUCTSINFO
GROUP BY
    Category
ORDER BY
    num_products DESC;

-- Check for NULL values
SELECT
    'product_id' AS column_name,
    COUNT(*) AS null_count
FROM
    PRODUCTSINFO
WHERE
    product_id IS NULL
UNION ALL
SELECT
    'Category' AS column_name,
    COUNT(*) AS null_count
FROM
    PRODUCTSINFO
WHERE
    Category IS NULL
UNION ALL
SELECT
    'product_name_length' AS column_name,
    COUNT(*) AS null_count
FROM
    PRODUCTSINFO
WHERE
    product_name_lenght IS NULL
UNION ALL
SELECT
    'product_description_length' AS column_name,
    COUNT(*) AS null_count
FROM
    PRODUCTSINFO
WHERE
    product_description_lenght IS NULL
UNION ALL
SELECT
    'product_photos_qty' AS column_name,
    COUNT(*) AS null_count
FROM
    PRODUCTSINFO
WHERE
    product_photos_qty IS NULL
UNION ALL
SELECT
    'product_weight_g' AS column_name,
    COUNT(*) AS null_count
FROM
    PRODUCTSINFO
WHERE
    product_weight_g IS NULL
UNION ALL
SELECT
    'product_length_cm' AS column_name,
    COUNT(*) AS null_count
FROM
    PRODUCTSINFO
WHERE
    product_length_cm IS NULL
UNION ALL
SELECT
    'product_height_cm' AS column_name,
    COUNT(*) AS null_count
FROM
    PRODUCTSINFO
WHERE
    product_height_cm IS NULL
UNION ALL
SELECT
    'product_width_cm' AS column_name,
    COUNT(*) AS null_count
FROM
    PRODUCTSINFO
WHERE
    product_width_cm IS NULL;
--there is one null for product width , lenght , height , width

SELECT * FROM RETAIL_ANALYSIS.PUBLIC.PRODUCTSINFO
WHERE CATEGORY = '#N/A'


UPDATE RETAIL_ANALYSIS.PUBLIC.PRODUCTSINFO
SET Category = 'Unknown'
WHERE Category = '#N/A';
-- Correlation between product weight and dimensions
SELECT
    CORR(product_weight_g, product_length_cm) AS corr_weight_length,
    CORR(product_weight_g, product_height_cm) AS corr_weight_height,
    CORR(product_weight_g, product_width_cm) AS corr_weight_width
FROM
RETAIL_ANALYSIS.PUBLIC.PRODUCTSINFO

SELECT * FROM RETAIL_ANALYSIS.PUBLIC.PRODUCTSINFO WHERE PRODUCT_WIDTH_CM IS NULL
--09ff539a621711667c43eba6a3bd8466 WITH CATEGORY BABY HAS NULL VALUE FOR WIDTH HEIGHT LENGHT



-----------------------------------------------------EDA OrderReview_Ratings------------------------------------------------------------------------------

SELECT COUNT (* ) FROM ORDERREVIEW_RATINGS;
--TOTAL RECORDS 100000

SELECT COUNT(DISTINCT ORDER_ID) FROM ORDERREVIEW_RATINGS;
--99441 DISTINCT ORDER ID

SELECT ORDER_ID,COUNT(ORDER_ID) FROM ORDERREVIEW_RATINGS GROUP BY ORDER_ID HAVING COUNT(ORDER_ID)>1;
--555 DUPLICATE ORDER_ID 

SELECT * FROM ORDERREVIEW_RATINGS WHERE ORDER_ID IS NULL
--THERE IS NO NULL VALUE


-- Create a new table to store deduplicated data
CREATE OR REPLACE TABLE ORDERREVIEW_RATINGS_DEDUPLICATED AS
SELECT * FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_id) AS rn
    FROM ORDERREVIEW_RATINGS
) subquery
WHERE rn = 1;


-- Verify the deduplication
SELECT COUNT(*), COUNT(DISTINCT order_id) FROM ORDERREVIEW_RATINGS_DEDUPLICATED;

ALTER TABLE ORDERREVIEW_RATINGS_DEDUPLICATED RENAME TO ORDERREVIEW_RATINGS;

select * from orderreview_ratings

-- Summary statistics
SELECT
    COUNT(*) AS num_orders,
    MIN(Customer_Satisfaction_Score) AS min_score,
    MAX(Customer_Satisfaction_Score) AS max_score,
    AVG(Customer_Satisfaction_Score) AS avg_score,
    MEDIAN(Customer_Satisfaction_Score) AS median_score,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Customer_Satisfaction_Score) AS percentile_25,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Customer_Satisfaction_Score) AS percentile_75
FROM
    ORDERREVIEW_RATINGS;


-- Distribution of satisfaction scores
SELECT
    Customer_Satisfaction_Score,
    COUNT(*) AS num_orders
FROM
    ORDERREVIEW_RATINGS
GROUP BY
    Customer_Satisfaction_Score
ORDER BY
    Customer_Satisfaction_Score;


-- Check for NULL values
SELECT
    COUNT(*) AS num_null_orders
FROM
    ORDERREVIEW_RATINGS
WHERE
    Customer_Satisfaction_Score IS NULL;


--  Join with ORDERS table
SELECT
    o.order_id,
    o.Customer_id,
    o.Bill_date_timestamp,
    r.Customer_Satisfaction_Score
FROM
    ORDERS o
INNER JOIN
    ORDERREVIEW_RATINGS r ON o.order_id = r.order_id;



------------------------------------------------------EDA Stores Info ----------------------------------------------------------------------------------

SELECT * FROM STORE_INFO


SELECT
    si.StoreID,
    si.seller_city,
    si.seller_state,
    si.Region,
    AVG(r.Customer_Satisfaction_Score) AS avg_satisfaction_score,
    COUNT(r.order_id) AS num_orders
FROM
    ORDERREVIEW_RATINGS r
INNER JOIN
    ORDERS o ON r.order_id = o.order_id
INNER JOIN
    STORE_INFO si ON o.Delivered_StoreID = si.StoreID
GROUP BY
    si.StoreID,
    si.seller_city,
    si.seller_state,
    si.Region
ORDER BY
    avg_satisfaction_score DESC;

---REGION WISE STORES COUNT
SELECT Region, COUNT(StoreID) AS num_stores
FROM STORE_INFO
GROUP BY Region
ORDER BY num_stores DESC;


--Average Number of Orders per Store
SELECT si.StoreID, si.seller_city, AVG(o.Quantity) AS avg_orders_per_store
FROM STORE_INFO si
INNER JOIN ORDERS o ON si.StoreID = o.Delivered_StoreID
GROUP BY si.StoreID, si.seller_city
ORDER BY avg_orders_per_store DESC;


SELECT DISTINCT STOREID FROM STORE_INFO
---THERE ARE 534 STORE ID
--NOTE THERE ARE 37 DISTINCT DELIVERED STOREID IN ORDER TABLE BUT HERE IN STORE_INFO IT THAS 534 STORE ID

SELECT DISTINCT STOREID FROM STORE_INFO AS S
INNER JOIN ORDERS AS O
ON S.STOREID = O.DELIVERED_STOREID

SELECT DISTINCT REGION FROM STORE_INFO
--4 REGIONS

SELECT DISTINCT SELLER_STATE FROM STORE_INFO
--19 DISTINCT STATES WHERE SELLER IS PRESENT

SELECT DISTINCT SELLER_CITY FROM STORE_INFO
--534 DISTINCT CITY SELLER IS PRESENT

SELECT SELLER_CITY,
       COUNT(STOREID) AS STORES 
       FROM STORE_INFO
       GROUP BY 1
-- EACH CITY HAS ONLY ONE STORE

SELECT COUNT( STOREID) FROM STORE_INFO
--535 RECORDS IN TABLE 

SELECT STOREID , COUNT(STOREID) FROM STORE_INFO GROUP BY STOREID HAVING COUNT(STOREID) >1
--SO THERE IS ONE DUPLICATE STOREID I.E ST410

SELECT * FROM STORE_INFO WHERE STOREID ='ST410'
--2 record for this id

--REMOVING THE DUPLICATE VALUE 
CREATE TABLE temp_store_info AS
SELECT
    StoreID,
    seller_city,
    seller_state,
    Region
FROM (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY StoreID ORDER BY StoreID) AS rn
    FROM store_info
) AS subquery
WHERE rn = 1;

DROP TABLE store_info;

ALTER TABLE temp_store_info
RENAME TO store_info;

SELECT StoreID, COUNT(*)
FROM store_info
GROUP BY StoreID
HAVING COUNT(*) > 1;


-----------------------------------------------EDA OrderPayments-------------------------------------------------------------------------------------------

SELECT * FROM ORDERPAYMENTS;

DESCRIBE orderpayments;

SELECT COUNT(*) AS total_records, 
       COUNT(DISTINCT order_id) AS unique_orders, 
       COUNT(DISTINCT payment_type) AS unique_payment_types 
FROM orderpayments;

--Check for Missing Values
SELECT 
    COUNT(*) AS total_records,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS missing_payment_type,
    SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END) AS missing_payment_value
FROM 
    orderpayments;

--Distribution of Payment Types
SELECT 
    payment_type,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orderpayments), 2) AS percentage
FROM 
    orderpayments
GROUP BY 
    payment_type
ORDER BY 
    count DESC;
    
--Statistical Summary of Payment Values
SELECT 
    MIN(payment_value) AS min_payment,
    MAX(payment_value) AS max_payment,
    AVG(payment_value) AS avg_payment,
    SUM(payment_value) AS total_payment,
    COUNT(*) AS total_transactions
FROM 
    orderpayments;

    
--Correlation Analysis
SELECT order_id, AVG(payment_value) AS avg_payment_value
FROM orderpayments
GROUP BY order_id;

--Data Integrity Checks
SELECT op.order_id
FROM orderpayments op
LEFT JOIN orders o ON op.order_id = o.order_id
WHERE o.order_id IS NULL;
--830 ORDER_ID

SELECT O.order_id
FROM orders o
LEFT JOIN orderpayments op  ON o.order_id = op.order_id 
WHERE PAYMENT_VALUE IS NULL;

--JOINING THE ORDERS WITH ORDERPAYMENTS
SELECT o.*, op.payment_type, op.payment_value
FROM orderpayments op
JOIN orders o ON op.order_id = o.order_id;

--Total Payment Amount by Payment Type
SELECT payment_type, SUM(payment_value) AS total_payment_amount
FROM OrderPayments
GROUP BY payment_type;


--Average Payment per Order
SELECT op.order_id, AVG(op.payment_value) AS avg_payment_per_order
FROM OrderPayments op
GROUP BY op.order_id;

SELECT DISTINCT PAYMENT_TYPE FROM ORDERPAYMENTS
-- 4 MODE OF PAYMENT

SELECT
    o.order_id,
    o.Total_Amount,
    op.payment_value,
    (o.Total_Amount - op.payment_value) AS difference
FROM ORDERPAYMENTS op
JOIN ORDERS o ON op.order_id = o.order_id
WHERE (o.Total_Amount - op.payment_value) != 0;
--24703 ROWS FOR WHICH TOTAL_AMOUNT = PAYMNET_VALUE IN PAYMENT TABLE 




----------------------------------CREATED A NEW TABLE WITH ALL ORDERS INFO------------------------------------------------------------------------------

CREATE OR REPLACE TABLE AdjustedOrdersTable AS
WITH AdjustedOrders AS (
    SELECT 
        o.ORDER_ID AS ODDD,
        p.AMOUNT,
        p.PAYMENT_TYPE,
        o.Customer_id,
        o.product_id,
        o.Channel,
        o.Delivered_StoreID,
        o.BILL_DATE_TIMESTAMP,
        O.COST_PER_UNIT,
        o.Quantity,
        o.MRP,
        o.Discount,
        o.TOTAL_AMOUNT,
        CASE 
            WHEN (o.Quantity * o.MRP - o.Quantity * o.Discount) = p.AMOUNT 
                THEN o.Quantity
            ELSE 
                ROUND(p.AMOUNT / (o.MRP - o.Discount), 0)
        END AS Adjusted_Quantity
    FROM
        orders o
    LEFT JOIN
        ORDERPAYMENTS p ON o.ORDER_ID = p.ORDER_ID
),
RankedOrders AS (
    SELECT  
        CUSTOMER_ID,
        PRODUCT_ID,
        AMOUNT ,
        PAYMENT_TYPE, 
        BILL_DATE_TIMESTAMP,
        CHANNEL,
        DELIVERED_STOREID,
        COST_PER_UNIT,
        ODDD, 
        Adjusted_Quantity, 
        MRP, 
        DISCOUNT, 
        TOTAL_AMOUNT, 
        (Adjusted_Quantity * MRP) - (Adjusted_Quantity * DISCOUNT) AS NEW_AMOUNT,
        ROW_NUMBER() OVER(PARTITION BY ODDD ORDER BY Adjusted_Quantity DESC) AS RANKS
    FROM AdjustedOrders
)
SELECT CUSTOMER_ID,
       PRODUCT_ID,
       CHANNEL,
       DELIVERED_STOREID,
       BILL_DATE_TIMESTAMP,
       COST_PER_UNIT,
    AMOUNT AS Payment_Value,
    PAYMENT_TYPE AS Payment_Type, 
    ODDD AS Order_ID, 
    Adjusted_Quantity AS Adjusted_Quantity, 
    MRP AS MRP, 
    DISCOUNT AS Discount,  
    NEW_AMOUNT AS New_Amount
FROM RankedOrders
--WHERE RANKS = 1;

CREATE OR REPLACE TABLE ORDERPAYMENTS AS 
SELECT ORDER_ID , PAYMENT_TYPE , SUM(PAYMENT_VALUE) AS AMOUNT FROM ORDERPAYMENTS GROUP BY ORDER_ID , PAYMENT_TYPE



SELECT * FROM ADJUSTEDORDERSTABLE;

SELECT ORDERS
SELECT DISTINCT DISCOUNT FROM ORDERS

SELECT * FROM PRODUCTSINFO


CREATE OR REPLACE TABLE ORDERS_INFO AS 
SELECT A.order_id,
        A.Customer_id,
        A.product_id,
        A.Channel,
        A.Delivered_StoreID,
        A.Bill_date_timestamp,
        A.Cost_Per_Unit,
        A.MRP,
        A.Discount,
        A.NEW_AMOUNT,
        A.ADJUSTED_QUANTITY,
        A.payment_type,
        A.payment_value,
        R.Customer_Satisfaction_Score,
        p.Category,
        p.product_name_lenght,
        p.product_description_lenght,
        p.product_photos_qty,
        p.product_weight_g,
        p.product_length_cm,
        p.product_height_cm,
        p.product_width_cm, FROM ADJUSTEDORDERSTABLE AS A
LEFT JOIN
 ORDERREVIEW_RATINGS AS R
 ON A.ORDER_ID = R.ORDER_ID
 LEFT JOIN 
 RETAIL_ANALYSIS.PUBLIC.PRODUCTSINFO AS P
 ON A.PRODUCT_ID = P.PRODUCT_ID


 

 CREATE OR REPLACE TABLE ORDERS_INFO  AS
SELECT
    A.order_id,
    A.Customer_id,
    A.product_id,
    A.Channel,
    A.Delivered_StoreID,
    A.Bill_date_timestamp,
    A.Cost_Per_Unit,
    A.MRP,
    A.Discount,
    A.NEW_AMOUNT,
    A.ADJUSTED_QUANTITY,
    A.payment_type,
    A.payment_value,
    R.Customer_Satisfaction_Score,
    P.Category,
    P.product_name_lenght AS product_name_length, -- Alias adjusted for SQL syntax
    P.product_description_lenght AS product_description_length, -- Alias adjusted for SQL syntax
    P.product_photos_qty,
    P.product_weight_g,
    P.product_length_cm,
    P.product_height_cm,
    P.product_width_cm
FROM ADJUSTEDORDERSTABLE AS A
LEFT JOIN ORDERREVIEW_RATINGS AS R ON A.ORDER_ID = R.ORDER_ID
LEFT JOIN RETAIL_ANALYSIS.PUBLIC.PRODUCTSINFO AS P ON A.PRODUCT_ID = P.PRODUCT_ID;

SELECT * FROM ORDERS_INFO

--CHECKING FOR NULL
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN Customer_id IS NULL THEN 1 ELSE 0 END) AS null_Customer_id,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN Channel IS NULL THEN 1 ELSE 0 END) AS null_Channel,
    SUM(CASE WHEN Delivered_StoreID IS NULL THEN 1 ELSE 0 END) AS null_Delivered_StoreID,
    SUM(CASE WHEN Cost_Per_Unit IS NULL THEN 1 ELSE 0 END) AS null_Cost_Per_Unit,
    SUM(CASE WHEN MRP IS NULL THEN 1 ELSE 0 END) AS null_MRP,
    SUM(CASE WHEN Discount IS NULL THEN 1 ELSE 0 END) AS null_Discount,
    SUM(CASE WHEN NEW_AMOUNT IS NULL THEN 1 ELSE 0 END) AS null_Total_Amount,
    SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS null_payment_type,
    SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END) AS null_payment_value,
    SUM(CASE WHEN Customer_Satisfaction_Score IS NULL THEN 1 ELSE 0 END) AS null_Customer_Satisfaction_Score,
    SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS null_Category,
    SUM(CASE WHEN PRODUCT_NAME_LENGHT IS NULL THEN 1 ELSE 0 END) AS null_product_name_lenght,
    SUM(CASE WHEN PRODUCT_DESCRIPTION_LENGHT IS NULL THEN 1 ELSE 0 END) AS null_product_description_lenght,
    SUM(CASE WHEN product_photos_qty IS NULL THEN 1 ELSE 0 END) AS null_product_photos_qty,
    SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END) AS null_product_weight_g,
    SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END) AS null_product_length_cm,
    SUM(CASE WHEN product_height_cm IS NULL THEN 1 ELSE 0 END) AS null_product_height_cm,
    SUM(CASE WHEN product_width_cm IS NULL THEN 1 ELSE 0 END) AS null_product_width_cm,
    SUM(CASE WHEN ADJUSTED_QUANTITY IS NULL THEN 1 ELSE 0 END) AS null_Quantity
FROM 
    ORDERS_INFO;

select * from orders_info
--THERE ARE THREE NULL VALUES IN PAYMNET_AVLUE AN PAYMNET_TYPE
-- DELETING THE NULL RECORDS 
DELETE FROM ORDERS_INFO
WHERE payment_type IS NULL;

SELECT * FROM ORDERS_INFO WHERE PAYMENT_TYPE IS NULL


SELECT * FROM (
SELECT ORDER_ID, (SUM(PAYMENT_VALUE)-SUM(NEW_AMOUNT)) AS DIFFERENCE FROM ORDERS_INFO GROUP BY ORDER_ID )WHERE DIFFERENCE >0;
--1002 RECORDS WHERE STILL PAYMNET ANOUNT AND NEW AMOUNT NOT MATCHING

SELECT * FROM ORDERS_INFO WHERE ORDER_ID = '07bca5c8ae457c75c959c5e26fc04e3f'
SELECT * FROM ORDERS_INFO WHERE ORDER_ID = '03ecec245220b63fd7f68c1737ba99ba'

DELETE FROM ORDERS_INFO 

SELECT PAYMENT_VALUE, NEW_AMOUNT, DISCOUNT,ADJUSTED_QUANTITY FROM ADJUSTEDORDERSTABLE
--1LK AROUND 
SELECT DISTINCT ORDER_ID  FROM ORDERPAYMENTS WHERE ORDER_ID NOT IN ( SELECT DISTINCT ORDER_ID FROM ORDERS_INFO)

SELECT * FROM ORDERS_INFO WHERE NEW_AMOUNT != PAYMENT_VALUE
SELECT  COUNT(DISTINCT ORDER_ID) FROM ORDERS --98666
UNION
SELECT COUNT(DISTINCT ORDER_ID) FROM ORDERPAYMENTS--99440
--774 ORDER ID IN ORDERPAYMNET MORE IN ORDERPAYMNET 

SELECT * FROM ORDERPAYMENTS AS P
LEFT JOIN ORDERS AS O
ON P.ORDER_ID = O.ORDER_ID
WHERE O.ORDER_ID IS NULL
--830 RECORDS

SELECT DISTINCT CATEGORY FROM ORDERS_INFO

--orders per customer_id 
select customer_id , count(order_id) as order_counts from orders_info group by customer_id order by 2 desc

SELECT 
    order_id, 
    Customer_id, 
    product_id, 
    COUNT(*) AS duplicate_count
FROM 
    orders_info
GROUP BY 
    order_id, 
    Customer_id, 
    product_id
HAVING 
    COUNT(*) > 1;
--there are duplicate records 




SELECT ORDER_ID, PRODUCT_ID , Customer_id ,QUANTITY ,MRP ,DISCOUNT ,TOTAL_AMOUNT , PAYMENT_VALUE FROM ORDERS_INFO WHERE TOTAL_AMOUNT != PAYMENT_VALUE

-- Schema Overview
DESC ORDERS_INFO

-- Basic Statistics
SELECT 
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT Customer_id) AS Unique_Customers,
    COUNT(DISTINCT order_id) AS Unique_Orders,
    COUNT(DISTINCT product_id) AS Unique_Products,
    COUNT(DISTINCT Delivered_StoreID) AS Unique_Stores
FROM ORDERS_INFO;

-- Summary Statistics for Numerical Columns
SELECT 
    AVG(Total_Amount) AS Avg_Total_Amount,
    STDDEV(Total_Amount) AS Stddev_Total_Amount,
    MIN(Total_Amount) AS Min_Total_Amount,
    MAX(Total_Amount) AS Max_Total_Amount,
    AVG(Quantity) AS Avg_Quantity,
    STDDEV(Quantity) AS Stddev_Quantity,
    MIN(Quantity) AS Min_Quantity,
    MAX(Quantity) AS Max_Quantity
FROM ORDERS_INFO;

--CUSTOMER
-- Number of Customers
WITH CTE1 AS (
SELECT COUNT(DISTINCT Customer_id) AS Number_of_Customers
FROM ORDERS_INFO
UNION
SELECT COUNT(DISTINCT CUSTID) FROM CUSTOMER)
SELECT * FROM CTE1
--867 CUSTOMER NOT PLACED ANY ORDER

-- Average Discount per Customer
SELECT AVG(Customer_Discount) AS Average_Discount_Per_Customer
FROM (
    SELECT Customer_id, SUM(Discount) AS Customer_Discount
    FROM ORDERS_INFO
    GROUP BY Customer_id
) AS Customer_Discounts;
--5.8775

-- Average Order Value
SELECT AVG(Total_Amount) AS Average_Order_Value
FROM ORDERS_INFO;

-- Average Sales per Customer
SELECT AVG(Customer_Sales) AS Average_Sales_Per_Customer
FROM (
    SELECT Customer_id, SUM(Total_Amount) AS Customer_Sales
    FROM ORDERS_INFO
    GROUP BY Customer_id
) AS Customer_Sales;

-- Average Profit per Customer
SELECT AVG(Customer_Profit) AS Average_Profit_Per_Customer
FROM (
    SELECT Customer_id, SUM(Total_Amount - Quantity * Cost_Per_Unit) AS Customer_Profit
    FROM ORDERS_INFO
    GROUP BY Customer_id
) AS Customer_Profits;

--AVG DISCOUNT/USER
SELECT AVG(Customer_Discount) AS Average_Discount_Per_Customer
FROM (
    SELECT Customer_id, SUM(Discount) AS Customer_Discount
    FROM ORDERS_INFO
    GROUP BY Customer_id
) AS Customer_Discounts;

SELECT 
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS Null_order_id,
    SUM(CASE WHEN Customer_id IS NULL THEN 1 ELSE 0 END) AS Null_Customer_id,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS Null_product_id,
    SUM(CASE WHEN Channel IS NULL THEN 1 ELSE 0 END) AS Null_Channel,
    SUM(CASE WHEN Delivered_StoreID IS NULL THEN 1 ELSE 0 END) AS Null_Delivered_StoreID,
    SUM(CASE WHEN Bill_date_timestamp IS NULL THEN 1 ELSE 0 END) AS Null_Bill_date_timestamp,
    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS Null_Quantity,
    SUM(CASE WHEN Cost_Per_Unit IS NULL THEN 1 ELSE 0 END) AS Null_Cost_Per_Unit,
    SUM(CASE WHEN MRP IS NULL THEN 1 ELSE 0 END) AS Null_MRP,
    SUM(CASE WHEN Discount IS NULL THEN 1 ELSE 0 END) AS Null_Discount,
    SUM(CASE WHEN Total_Amount IS NULL THEN 1 ELSE 0 END) AS Null_Total_Amount,
    SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS Null_payment_type,
    SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END) AS Null_payment_value,
    SUM(CASE WHEN Customer_Satisfaction_Score IS NULL THEN 1 ELSE 0 END) AS Null_Customer_Satisfaction_Score,
    SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS Null_Category,
    SUM(CASE WHEN PRODUCT_NAME_LENGHT IS NULL THEN 1 ELSE 0 END) AS Null_product_name_length,
    SUM(CASE WHEN product_description_lenght IS NULL THEN 1 ELSE 0 END) AS Null_product_description_length,
    SUM(CASE WHEN product_photos_qty IS NULL THEN 1 ELSE 0 END) AS Null_product_photos_qty,
    SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END) AS Null_product_weight_g,
    SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END) AS Null_product_length_cm,
    SUM(CASE WHEN product_height_cm IS NULL THEN 1 ELSE 0 END) AS Null_product_height_cm,
    SUM(CASE WHEN product_width_cm IS NULL THEN 1 ELSE 0 END) AS Null_product_width_cm
FROM ORDERS_INFO;




SELECT * FROM ORDERS_INFO WHERE PAYMENT_VALUE IS NULL;
--THERE ARE 3 RECORDS OUT OF 118318 I.E ONLE 0.0025% OF WHOLE RECORDS



SELECT * FROM ORDERS_INFO WHERE PAYMENT_TYPE IS null or payment_value is null
--THERE ARE THREE ORDER WHERE PAYMENT TYPE IS NULL

SELECT COUNT(DISTINCT PRODUCT_ID) FROM ORDERS_INFO
--32951 DISTINCT PRODUCT_ID

SELECT DISTINCT PRODUCT_ID FROM ORDERS_INFO WHERE CATEGORY IS NULL
--THERE ARE 623 PRODUCT ID WHERE CATEGORY IS NULL I.E. 1.89% OF TOTAL DISTINC PRODUCT_ID

SELECT CATEGORY ,COUNT(CATEGORY) FROM ORDERS_INFO GROUP BY CATEGORY


SELECT 
    SUM(Total_Amount) AS sum_total_amount,
    SUM(payment_value) AS sum_payment_value
FROM ORDERS_INFO;


--Identify Mismatched Rows
SELECT *
FROM ORDERS_INFO
WHERE Total_Amount <> payment_value;



-- Identify Problematic Rows

SELECT
    order_id,
    product_id,
    Customer_id,
    COUNT(*) AS num_entries
FROM ORDERS_INFO
GROUP BY order_id, product_id, Customer_id
HAVING COUNT(*) > 1;


SELECT
    order_id,
    product_id,
    Customer_id,
    COUNT(*) AS num_entries,
    STRING_AGG(CAST(Quantity AS STRING), ', ' ORDER BY Quantity) AS quantity_series
FROM ORDERS_INFO
GROUP BY order_id, product_id, Customer_id
HAVING COUNT(*) > 1;

SELECT
    order_id,
    product_id,
    Customer_id,
    Channel,
    Delivered_StoreID,
    Bill_date_timestamp,
    SUM(Quantity) AS consolidated_quantity,
    AVG(Cost_Per_Unit) AS avg_cost_per_unit,
    AVG(MRP) AS avg_mrp,
    AVG(Discount) AS avg_discount,
    SUM(Total_Amount) AS consolidated_total_amount,
    MAX(payment_type) AS payment_type,
    MAX(payment_value) AS payment_value,
    MAX(Customer_Satisfaction_Score) AS Customer_Satisfaction_Score,
    MAX(Category) AS Category,
    MAX(product_name_lenght) AS product_name_lenght,
    MAX(product_description_lenght) AS product_description_lenght,
    MAX(product_photos_qty) AS product_photos_qty,
    MAX(product_weight_g) AS product_weight_g,
    MAX(product_length_cm) AS product_length_cm,
    MAX(product_height_cm) AS product_height_cm,
    MAX(product_width_cm) AS product_width_cm
FROM ORDERS_INFO
GROUP BY
    order_id,
    product_id,
    Customer_id,
    Channel,
    Delivered_StoreID,
    Bill_date_timestamp;


-------------------------------------------------------------------------------------------------------------------------------------------------------


----------------------------------CREATED A NEW TABLE WITH ALL STORE INFO------------------------------------------------------------------------------
CREATE OR REPLACE TABLE STORES_INFO AS
SELECT O.DELIVERED_STOREID, S.SELLER_CITY, S.SELLER_STATE, S.REGION, O.CHANNEL
FROM ORDERS AS O 
LEFT JOIN STORE_INFO AS S
ON  O.DELIVERED_STOREID= S.STOREID ;

SELECT * FROM STORES_INFO;

--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------Perform Detailed exploratory analysis --------------------------------------------------------------



--Percentage of Discount
SELECT (SUM(Discount) / SUM(MRP)) * 100 AS percentage_of_discount FROM ORDERS_INFO;
--3.363% 

--Percentage of Profit
SELECT (SUM(Total_Amount - Cost_Per_Unit * Quantity) / SUM(Total_Amount)) * 100 AS percentage_of_profit FROM ORDERS_INFO;


--Repeat Purchase Rate
SELECT (COUNT(DISTINCT Customer_id) - COUNT(DISTINCT CASE WHEN customer_orders = 1 THEN Customer_id END)) / COUNT(DISTINCT Customer_id) * 100 AS repeat_purchase_rate
FROM (
    SELECT Customer_id, COUNT(order_id) AS customer_orders
    FROM ORDERS_INFO
    GROUP BY Customer_id
) AS customer_order_counts;
--13.137200 % 


--One-time Buyers Percentage
SELECT COUNT(DISTINCT CASE WHEN customer_orders = 1 THEN Customer_id END) / COUNT(DISTINCT Customer_id) * 100 AS one_time_buyers_percentage
FROM (
    SELECT Customer_id, COUNT(order_id) AS customer_orders
    FROM ORDERS_INFO
    GROUP BY Customer_id
) AS customer_order_counts;
--86.86% ARE ONE TIME BUYER


--Repeat Customer Percentage
SELECT (COUNT(Customer_id) - COUNT(DISTINCT CASE WHEN customer_orders = 1 THEN Customer_id END)) / COUNT(Customer_id) * 100 AS repeat_customer_percentage
FROM (
    SELECT Customer_id, COUNT(order_id) AS customer_orders
    FROM ORDERS_INFO
    GROUP BY Customer_id
) AS customer_order_counts;
--ONLY 13.13 %


--Transactions per Customer
SELECT AVG(transaction) AS transactions_per_customer
FROM (
    SELECT Customer_id, COUNT(order_id) AS transaction
    FROM ORDERS_INFO
    GROUP BY Customer_id
) AS customer_transactions;


--Total Locations
SELECT COUNT(DISTINCT CONCAT(seller_city, '_', seller_state)) AS total_locations FROM STORE_INFO;

-- Average Number of Days Between Two Transactions (if the customer has more than one transaction)
SELECT AVG(days_between_transactions) AS average_days_between_transactions
FROM (
    SELECT 
        Customer_id,
        DATEDIFF('day', Bill_date_timestamp, LEAD(Bill_date_timestamp) OVER (PARTITION BY Customer_id ORDER BY Bill_date_timestamp)) AS days_between_transactions
    FROM ORDERS_INFO
) AS customer_days_between
WHERE Customer_id IN (
    SELECT Customer_id
    FROM ORDERS_INFO
    GROUP BY Customer_id
    HAVING COUNT(order_id) > 1
);

--Understanding how many new customers acquired every month (who made transaction first time in the data)

WITH FirstTransactions AS (
    SELECT
        Customer_id,
        MIN(Bill_date_timestamp) AS first_transaction_date
    FROM
        ORDERS_INFO
    GROUP BY
        Customer_id
)
SELECT
    DATE_TRUNC('month',TO_DATE( first_transaction_date)) AS month,
    COUNT(*) AS new_customers_acquired
FROM
    FirstTransactions
GROUP BY
    DATE_TRUNC('month',TO_DATE( first_transaction_date))
ORDER BY
    month;

-------------------------Understand the behavior of discount seekers & non discount seekers
SELECT COUNT(DISTINCT A.Customer_id) AS NON_DISCOUNT_SEEKER FROM Orders AS A --NON_DISCOUNT_SEEKER ARE 56532
WHERE A.Discount = 0 AND A.Customer_id NOT IN (SELECT DISTINCT A.Customer_id FROM Orders AS A
WHERE A.Discount > 0)


SELECT COUNT(DISTINCT A.Customer_id) AS DISCOUNT_SEEKER FROM Orders AS A --DISCOUNT_SEEKER ARE 42043
WHERE A.Discount > 0

--BEHAVIOUR OF DISCOUNT SEEKER
SELECT B.Customer_id,SUM(B.Discount) AS Total_Discount FROM Orders AS B
WHERE B.Customer_id IN (SELECT DISTINCT A.Customer_id FROM Orders AS A 
WHERE A.Discount > 0)
GROUP BY B.Customer_id
ORDER BY SUM(B.Discount) DESC 
--HIGHEST DISCOUNT PROVIDED TO "7444228609" CUSTOMER

SELECT B.Delivered_StoreID AS STORE,COUNT(DISTINCT B.Customer_id) AS Cust_Count FROM Orders AS B
WHERE B.Customer_id IN (SELECT DISTINCT A.Customer_id FROM Orders AS A 
WHERE A.Discount > 0)
GROUP BY B.Delivered_StoreID 
ORDER BY COUNT(DISTINCT B.Customer_id) DESC 
--OUT OF 42043 DISCOUNT SEEKERS 8980 PURCHASING FROM ST103 & 3764 PURCHASING FROM ST143

SELECT D.Region,COUNT(DISTINCT F.Customer_id) AS Cust_Count FROM Orders AS F
LEFT JOIN 
StoresInfo AS D
ON F.Delivered_StoreID = D.StoreID
WHERE F.Customer_id IN (SELECT DISTINCT A.Customer_id FROM Orders AS A 
WHERE A.Discount > 0)
GROUP BY D.Region
ORDER BY COUNT(DISTINCT F.Customer_id) DESC
--OUT OF 42043 DISCOUNT SEEKERS 31572 FROM SOUTH

SELECT D.seller_state AS State_,COUNT(DISTINCT F.Customer_id) AS Cust_Count FROM Orders AS F
LEFT JOIN 
StoresInfo AS D
ON F.Delivered_StoreID = D.StoreID
WHERE F.Customer_id IN (SELECT DISTINCT A.Customer_id FROM Orders AS A 
WHERE A.Discount > 0)
GROUP BY D.seller_state
ORDER BY COUNT(DISTINCT F.Customer_id) DESC
--OUT OF 42043 DISCOUNT SEEKERS 31572 FROM ANDHRA PRADESH

--BEHAVIOUR OF NON-DISCOUNT SEEKER 
SELECT B.Delivered_StoreID AS STORE,COUNT(DISTINCT B.Customer_id) AS Cust_Count FROM Orders AS B
WHERE B.Customer_id IN (SELECT DISTINCT A.Customer_id FROM Orders AS A 
WHERE A.Discount = 0 AND A.Customer_id NOT IN (SELECT DISTINCT A.Customer_id FROM Orders AS A
WHERE A.Discount > 0))
GROUP BY B.Delivered_StoreID 
ORDER BY COUNT(DISTINCT B.Customer_id) DESC 
----OUT OF 56532 NON DISCOUNT SEEKERS 16442 PURCHASING FROM ST103 & 3855 PURCHASING FROM ST143

SELECT D.Region,COUNT(DISTINCT F.Customer_id) AS Cust_Count FROM Orders AS F
LEFT JOIN 
StoresInfo AS D
ON F.Delivered_StoreID = D.StoreID
WHERE F.Customer_id IN (SELECT DISTINCT A.Customer_id FROM Orders AS A 
WHERE A.Discount = 0 AND A.Customer_id NOT IN (SELECT DISTINCT A.Customer_id FROM Orders AS A
WHERE A.Discount > 0))
GROUP BY D.Region
ORDER BY COUNT(DISTINCT F.Customer_id) DESC 
--OUT OF 56532 NON DISCOUNT SEEKERS 44512 FROM SOUTH

SELECT D.seller_state AS STATE_,COUNT(DISTINCT F.Customer_id) AS Cust_Count FROM Orders AS F
LEFT JOIN 
StoresInfo AS D
ON F.Delivered_StoreID = D.StoreID
WHERE F.Customer_id IN (SELECT DISTINCT A.Customer_id FROM Orders AS A 
WHERE A.Discount = 0 AND A.Customer_id NOT IN (SELECT DISTINCT A.Customer_id FROM Orders AS A
WHERE A.Discount > 0))
GROUP BY D.seller_state
ORDER BY COUNT(DISTINCT F.Customer_id) DESC
--OUT OF 56532 NON DISCOUNT SEEKERS 44512 FROM ANDHRA PRADESH

--Top 10-performing & worst 10 performance stores in terms of sales
SELECT
    Delivered_StoreID AS store_id,
    SUM(Total_Amount) AS total_sales
FROM
    ORDERS_INFO
GROUP BY
    Delivered_StoreID
ORDER BY
    total_sales DESC
LIMIT 10;

--WORST PERFORMING
SELECT
    Delivered_StoreID AS store_id,
    SUM(Total_Amount) AS total_sales
FROM
    ORDERS_INFO
GROUP BY
    Delivered_StoreID
ORDER BY
    total_sales ASC
LIMIT 10;

--Which product appeared in the transactions?
SELECT DISTINCT product_id
FROM ORDERS_INFO;

--List the top 10 most expensive products sorted by price and their contribution to sales

SELECT TOP 10 
       PRODUCT_ID,
       MRP, 
       SUM(TOTAL_AMOUNT) AS SALES 
FROM 
    ORDERS_INFO
GROUP BY 
    PRODUCT_ID , MRP
ORDER BY MRP DESC

--Popular categories/Popular Products by store, state, region. 
SELECT CATEGORY , COUNT(DELIVERED_STOREID) AS COUNTS FROM ORDERS_INFO GROUP BY CATEGORY



--GENDER WISE PREFERENCE OF CHANNEL
SELECT GENDER,CHANNEL ,COUNT(ORDER_ID) FROM CUSTOMER AS C
INNER JOIN ORDERS_INFO AS O
ON C.CUSTID = O.CUSTOMER_ID
GROUP BY 1,2

--STATE WISE SALES
SELECT CUSTOMER_STATE,SUM(TOTAL_AMOUNT) AS SALES  FROM CUSTOMER AS C
INNER JOIN ORDERS_INFO AS O
ON C.CUSTID = O.CUSTOMER_ID
GROUP BY 1
ORDER BY 2 DESC




--Popular categories/Popular Products by store, state, region. 

SELECT  CUSTOMER_CITY,CUSTOMER_STATE,DELIVERED_STOREID,PRODUCT_ID,COUNT(PRODUCT_ID) AS COUNTS FROM CUSTOMER AS C  
INNER JOIN ORDERS AS O
ON C.CUSTID = O.CUSTOMER_ID 
GROUP BY 1,2,3,4
ORDER BY 5 DESC


SELECT GENDER,PAYMENT_TYPE,SUM(PAYMENT_VALUE) AS VALUE_SPENT  FROM ORDERS AS O
INNER JOIN ORDERPAYMENTS AS P
ON O.ORDER_ID = P.ORDER_ID
INNER JOIN CUSTOMER AS C
ON C.CUSTID  = O.CUSTOMER_ID
GROUP BY 1,2
ORDER BY GENDER
--GENDER WISE USE OF MODE OF PAYMENT



select CUSTOMER_ID,O.ORDER_ID,PRODUCT_ID , CHANNEL , DELIVERED_STOREID , BILL_DATE_TIMESTAMP , QUANTITY, COST_PER_UNIT, MRP, DISCOUNT, TOTAL_AMOUNT , CUSTOMER_SATISFACTION_SCORE from ORDERREVIEW_RATINGS AS R
INNER JOIN ORDERS AS O
ON O.ORDER_ID = R.ORDER_ID
ORDER BY CUSTOMER_SATISFACTION_SCORE DESC;

--PRODUCT AND ORDER WITH HIGH CUSTOMER_SATISFACTION_SCORE
select CUSTOMER_ID,O.ORDER_ID,PRODUCT_ID , CUSTOMER_SATISFACTION_SCORE from ORDERREVIEW_RATINGS AS R
INNER JOIN ORDERS AS O
ON O.ORDER_ID = R.ORDER_ID
WHERE CUSTOMER_SATISFACTION_SCORE = 5
;

--PRODUCT AND ORDER WITH LOW CUSTOMER_SATISFACTION_SCORE
select CUSTOMER_ID,O.ORDER_ID,PRODUCT_ID , CUSTOMER_SATISFACTION_SCORE from ORDERREVIEW_RATINGS AS R
INNER JOIN ORDERS AS O
ON O.ORDER_ID = R.ORDER_ID
WHERE CUSTOMER_SATISFACTION_SCORE <=2.5;




--Total products, Total categories, Total stores, Total locations, Total Regions, Total channels, Total payment methods, Total Revenue, Total Profit,  Total Cost, Total quantity


SELECT COUNT(DISTINCT product_id) AS TOTAL_PRODUCTS,
       COUNT(DISTINCT CHANNEL) AS TOTAL_CHANNEL,
       SUM(TOTAL_AMOUNT) AS TOTAL_AMT ,
       COUNT(DISTINCT PAYMENT_TYPE) AS PAYMENT_METHODS ,
       SUM(QUANTITY) AS TOTAL_QUANTITY,
       SUM(COST_PER_UNIT) AS TOTAL_COST,
       SUM(DISCOUNT) AS TOTAL_DISCOUNT,
       (SUM(TOTAL_AMOUNT)-SUM(COST_PER_UNIT)) AS TOTAL_PROFIT,
       COUNT(DISTINCT CATEGORY)AS TOTAL_CATEGORIES,
       COUNT(DISTINCT DELIVERED_STOREID) AS STORE_COUNT FROM ORDERS_INFO

SELECT COUNT(DISTINCT CUSTID) AS TOTAL_CUST,
       COUNT(DISTINCT CUSTOMER_CITY) AS CUST_CITIES,
       COUNT(DISTINCT CUSTOMER_STATE) AS STATES_CUST,
       COUNT(DISTINCT GENDER) AS GENDER_COUNT
       FROM CUSTOMER

SELECT COUNT(DISTINCT SELLER_STATE) AS SELLER_STS,
       COUNT(DISTINCT SELLER_CITY) AS SELLER_CITIES,
       COUNT(DISTINCT REGION) AS REGIONS
       FROM STORES_INFO

SELECT CUSTOMER_ID,
       COUNT( CUSTOMER_ID ) 
       FROM ORDERS 
       GROUP BY CUSTOMER_ID 
       HAVING COUNT(CUSTOMER_ID)>1 
       ORDER BY COUNT(CUSTOMER_ID) DESC
--THERE ARE 9828 CUSTOMER WHICH ARE HAVING COUNT IN ORDER TABLE MORE THAN 1


--LIST OF CUSTOMER WHO NOT ORDERED EVEN ONCE
SELECT *  FROM CUSTOMER AS C
LEFT JOIN ORDERS_INFO AS O
ON C.CUSTID = O.CUSTOMER_ID
WHERE ORDER_ID IS NULL


---------------------------------------------------MONTHLY ANALYSIS--------------------------------------------------
SELECT 
       MONTH(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP)))  AS MONTH,
       SUM(TOTAL_AMOUNT) AS SALES ,
       COUNT(ORDER_ID) AS ORDERS_NO
       FROM ORDERS
       WHERE YEAR(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP)))=2023
       GROUP BY 1
       ORDER BY 3
-- IN 2023 , IN SEPT MONTH LEAST ORDERS PLACED AND MAX ORDERS PLACED IN AUGUST
SELECT * FROM ORDERS
SELECT 
       MONTH(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP)))  AS MONTH,
       SUM(TOTAL_AMOUNT) AS SALES ,
       COUNT(ORDER_ID) AS ORDERS_NO
       FROM ORDERS
       WHERE YEAR(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP)))=2022
       GROUP BY 1
       ORDER BY 3
-- IN 2022 , IN JAN MONTH LEAST ORDERS PLACED AND MAX ORDERS PLACED IN DECEMBER

SELECT 
       MONTH(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP)))  AS MONTH,
       SUM(TOTAL_AMOUNT) AS SALES ,
       COUNT(ORDER_ID) AS ORDERS_NO
       FROM ORDERS
       WHERE YEAR(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP)))=2021
       GROUP BY 1
       ORDER BY 3

SELECT 
       MONTH(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP)))  AS MONTH,
       SUM(TOTAL_AMOUNT) AS SALES ,
       COUNT(ORDER_ID) AS ORDERS_NO
       FROM ORDERS
       WHERE YEAR(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP)))=2020
       GROUP BY 1
       ORDER BY 3
-- IN 2021 , DEC MONTH LEAST ORDERS PLACED AND MAX ORDERS PLACED IN OCT AND THE DIFFERNCE IN SAALES AMOUNT IS HUGE
--IN OCT- AMOUNT = 65334 AND IN DEC = 19.5 ONLY


SELECT GENDER ,YEAR(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP))) AS YEARS,
       SUM(TOTAL_AMOUNT) AS SALES ,
       COUNT(ORDER_ID) AS ORDERS_NO  FROM CUSTOMER AS C
INNER JOIN ORDERS AS O
ON C.CUSTID = O.CUSTOMER_ID
GROUP BY 1,2
ORDER BY 2 DESC
----------------------------------------------------------------------------------------------------------------------

--Understanding how many new customers acquired every month (who made transaction first time in the data)

--YEARLY NEW CUSTOMER
SELECT YEAR(FIRST_ORDER)  AS YEARS,
       COUNT(CUSTOMER_ID) AS NEW_CUST
       FROM(
            SELECT CUSTOMER_ID , MIN(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP))) AS FIRST_ORDER
            FROM ORDERS
            GROUP BY 1
       ) FIRST
       GROUP BY 1

--MONTHLYY NEW CUSTOMER
SELECT MONTH(FIRST_ORDER)  AS MONTHS,
       COUNT(CUSTOMER_ID) AS NEW_CUST
       FROM(
            SELECT CUSTOMER_ID , MIN(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP))) AS FIRST_ORDER
            FROM ORDERS
            GROUP BY 1
       ) FIRST
       GROUP BY 1
       ORDER BY 2 DESC

SELECT CUSTOMER_ID,
       (SUM(TOTAL_AMOUNT)-SUM(COST_PER_UNIT) ) /SUM(TOTAL_AMOUNT) AS TOTAL_PROFIT_PERC 
       FROM ORDERS
       GROUP BY CUSTOMER_ID 
       ORDER BY 2 DESC
--TOTAL PROFIT PERCENTAGE / CUSTOMER


SELECT CUSTOMER_ID , 
       COUNT(ORDER_ID) 
       FROM ORDERS 
       GROUP BY CUSTOMER_ID 
       ORDER BY 2 DESC
-- NO OF ORDERS PER CUSTOMER ID

--ORDER NUM AND TOTAL SALES BY YEARS
SELECT YEAR(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP)))  AS YEARS,
       SUM(TOTAL_AMOUNT) AS SALES ,
       COUNT(ORDER_ID) AS ORDERS_NO
       FROM ORDERS
       GROUP BY 1

--PROMOTION EFFECTIVENESS AND EFFICIENCY BY YEARS 
SELECT YEAR(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP)))  AS YEARS,
       SUM(TOTAL_AMOUNT) AS SALES,
       SUM(DISCOUNT) AS PROMOTION,
       ROUND(SUM(DISCOUNT)*100/SUM(TOTAL_AMOUNT),2) AS BURN_RATE
       FROM ORDERS
       GROUP BY 1
       
--CUSTOMER TRANSACTION PER YEAR
SELECT YEAR(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP)))  AS YEARS,
       COUNT(DISTINCT CUSTOMER_ID) AS NO_OF_CUST
       FROM ORDERS_INFO
       GROUP BY 1;

-- GEDER WISE TOTAL SALE AMOUNT 
SELECT GENDER, 
       SUM(TOTAL_AMOUNT) AS TOTAL_SALE,
       COUNT(O.ORDER_ID) AS TOTAL_ORDERS 
       FROM CUSTOMER AS C
       INNER JOIN ORDERS_INFO AS O
       ON C.CUSTID = O.CUSTOMER_ID
       GROUP BY 1
--CONCLUSION- SALES DONE BY FEMALES ARE NEARLY DOUBLE THE SALES DONE BY MALES

SELECT CUSTOMER_ID ,
       AVG(TOTAL_AMOUNT) AS TOTAL_AVG_SALE 
       FROM ORDERS 
       GROUP BY CUSTOMER_ID 
       ORDER BY AVG(TOTAL_AMOUNT) DESC
--AVG SALE PER CUSTOMER


--Top 10-performing  stores in terms of sales
SELECT TOP 10 
       DELIVERED_STOREID,
       SUM(TOTAL_AMOUNT) AS TOTAL 
       FROM ORDERS_INFO
       GROUP BY 1 
       ORDER BY 2 DESC

--worst 10 performance stores in terms of sales
SELECT TOP 10 
       DELIVERED_STOREID,
       SUM(TOTAL_AMOUNT) AS TOTAL 
       FROM ORDERS_INFO 
       GROUP BY 1 
       ORDER BY 2 ASC 


--List the top 10 most expensive products sorted by price and their contribution to sales
SELECT TOP 10  
       PRODUCT_ID,COST_PER_UNIT , 
       SUM(TOTAL_AMOUNT) AS SALES 
       FROM ORDERS  
       GROUP BY 1,2 
       ORDER BY 2 DESC

--Popular categories/Popular Products by store, state, region. 
SELECT CATEGORY , STOREID ,SELLER_STATE, REGION,SUM(QUANTITY) AS TOTAL_QUANTITY FROM ORDERS_INFO AS O
INNER JOIN STORE_INFO AS S
ON O.DELIVERED_STOREID = S.STOREID
GROUP BY CATEGORY , STOREID, SELLER_STATE, REGION
ORDER BY 5 DESC


SELECT CATEGORY FROM ORDERS_INFO WHERE CATEGORY= '#N/A';


---------------------------------------------------------------------------ANALYSIS------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT TOP 10 
       PRODUCT_ID , 
       sum(TOTAL_AMOUNT) AS SALES 
       FROM ORDERS GROUP BY PRODUCT_ID
       ORDER BY 2 DESC;
--TOP 10 PRODUCT ID BY SALES AMOUNT

SELECT CHANNEL , 
       COUNT(ORDER_ID) AS ORDER_COUNT  
       FROM ORDERS GROUP BY CHANNEL 
       ORDER BY  COUNT(ORDER_ID) DESC
--MAX ORDER BY INSTORE CHANNEL THEN PHONE DELIVERY AND THEN ONLINE

SELECT TOP 5 
       CUSTOMER_ID , 
       SUM(TOTAL_AMOUNT) AS TOTAL_SPEND 
       FROM ORDERS GROUP BY CUSTOMER_ID 
       ORDER BY SUM(TOTAL_AMOUNT) DESC;
--TOP 5 CUST_ID BY TOTAL_SPEND

SELECT TOP 5 
       CUSTOMER_ID , 
       SUM(QUANTITY) AS TOTAL_QNT_ORDERED 
       FROM ORDERS GROUP BY CUSTOMER_ID 
       ORDER BY 2 DESC;

SELECT TOP 5
       CUSTOMER_ID, 
       (TOTAL_AMOUNT - COST_PER_UNIT) AS REVENUE 
       FROM ORDERS
       ORDER BY 2 DESC
--TOP 5 CUSTOMER GIVING MAX REVENUE

SELECT TOP 5
       PRODUCT_ID, 
       (TOTAL_AMOUNT - COST_PER_UNIT) AS REVENUE 
       FROM ORDERS
       ORDER BY 2 DESC
--TOP 5 PRODUCT GIVING MAX REVENUE

SELECT * FROM ORDERS

SELECT CHANNEL ,
       SUM(TOTAL_AMOUNT) AS TOTAL_SPEND 
       FROM ORDERS 
       GROUP BY CHANNEL 
       ORDER BY  SUM(TOTAL_AMOUNT) DESC
--MAX AMOUNT SPEND THROUGH INSTORE ORDERS



SELECT CONCAT(( SUM(TOTAL_AMOUNT)-SUM(COST_PER_UNIT) ) *100/SUM(TOTAL_AMOUNT),'%') AS TOTAL_PROFIT_PERC FROM ORDERS
--TOTAL PROFIT IN % IS 24.74%

SELECT YEAR(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP)))  AS YEARS, SUM(TOTAL_AMOUNT) AS TOTAL_AMT FROM ORDERS GROUP BY YEAR(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP)))
--YEARLY TOTAL_AMOUNT OF ORDERS 
--TOTAL AMOUNT IN 2020 BY SELLING PRODUCT IS JUST 659.63 AS THERE ARE ONLY 4 ORDERS IN 2020


SELECT CUSTOMER_ID ,AVG(DISCOUNT) AS TOTAL_DISCOUNT FROM ORDERS GROUP BY CUSTOMER_ID ORDER BY AVG(DISCOUNT)DESC
--AVG DISCOUNT PER CUSTOMER_ID



SELECT COUNT(CUSTOMER_ID) FROM (
SELECT CUSTOMER_ID ,AVG(DISCOUNT) AS TOTAL_DISCOUNT FROM ORDERS GROUP BY CUSTOMER_ID HAVING AVG(DISCOUNT) = 0) AS X
--CUSTOMER NOT RECIEVED ANY DISCOUNT

select count(customer_id) from (
SELECT CUSTOMER_ID ,AVG(DISCOUNT) AS TOTAL_DISCOUNT FROM ORDERS GROUP BY CUSTOMER_ID HAVING AVG(DISCOUNT) >0) as x
--CUSTOMER WHO RECIEVED DISCOUNT


--YEARLY NEW CUSTOMER
SELECT YEAR(FIRST_ORDER)  AS YEARS,
       COUNT(CUSTOMER_ID) AS NEW_CUST
       FROM(
            SELECT CUSTOMER_ID , MIN(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP))) AS FIRST_ORDER
            FROM ORDERS
            GROUP BY 1
       ) FIRST
       GROUP BY 1
-----------------------------------------------------------------------------------------------------------------------




----------------------. Customer Behaviour Analysis--------------------------------------------------------------------

SELECT
    Customer_id,
    SUM(NEW_AMOUNT) AS lifetime_value
FROM ORDERS_INFO
GROUP BY Customer_id
ORDER BY lifetime_value DESC;

--TOTAL AND AVG SPEND BY CUSTOMER
SELECT
    A.Customer_id,
    SUM(A.NEW_AMOUNT) AS total_spend,
    AVG(A.NEW_AMOUNT) AS avg_spend
FROM ORDERS_INFO AS A
GROUP BY A.Customer_id
ORDER BY total_spend DESC;

--Customer Retention Analysis
WITH customer_orders AS (
    SELECT
        A.Customer_id,
        COUNT(DISTINCT A.ORDER_ID) AS order_count
    FROM ORDERS_INFO AS A
    GROUP BY A.Customer_id
)
SELECT
    CO.Customer_id,
    CO.order_count,
    CASE 
        WHEN CO.order_count = 1 THEN 'One-time'
        WHEN CO.order_count BETWEEN 2 AND 5 THEN 'Occasional'
        ELSE 'Frequent'
    END AS customer_type
FROM customer_orders CO
ORDER BY CO.order_count DESC;

-- Average Time Between Purchases
WITH customer_dates AS (
    SELECT
        A.Customer_id,
        A.Bill_date_timestamp,
        LAG(A.Bill_date_timestamp) OVER (PARTITION BY A.Customer_id ORDER BY A.Bill_date_timestamp) AS prev_date
    FROM ORDERS_INFO AS A
)
SELECT TOP 5
    Customer_id,
    AVG(DATEDIFF('days', Bill_date_timestamp, prev_date)) AS avg_days_between_purchases
FROM customer_dates
WHERE prev_date IS NOT NULL
GROUP BY Customer_id
ORDER BY avg_days_between_purchases;




SELECT * FROM

--Segment the customers (divide the customers into groups) based on the revenue
WITH SEGMENTS AS (
SELECT
    Customer_id,
    SUM(NEW_AMOUNT) AS Total_Revenue,
    CASE
        WHEN SUM(NEW_AMOUNT) > 10000 THEN 'OVER HIGH Revenue'
        WHEN SUM(NEW_AMOUNT) < 1000 THEN 'Low Revenue'
        WHEN SUM(NEW_AMOUNT) >= 1000 AND SUM(NEW_AMOUNT) < 5000 THEN 'Medium Revenue'
        WHEN SUM(NEW_AMOUNT) >= 5000 THEN 'High Revenue'
        ELSE 'Other'
    END AS Revenue_Segment
FROM
    ORDERS_INFO
   
GROUP BY
    Customer_id)
    SELECT REVENUE_SEGMENT , COUNT(*) AS CUSTOMERS FROM SEGMENTS GROUP BY REVENUE_SEGMENT

--Divide the customers into groups based on Recency, Frequency, and Monetary (RFM Segmentation) -  Divide the customers into Premium, Gold, Silver, Standard customers and understand the behaviour of each segment of customers
SELECT * FROM ORDERS_INFO

--Calculate Recency (R)
SELECT
    Customer_id,
    DATEDIFF(day, MIN(BILL_DATE_TIMESTAMP), MAX(BILL_DATE_TIMESTAMP)) AS RECENCY
FROM
    ORDERS_INFO
GROUP BY
    Customer_id;
-- CALCULATE FREQUENCY
SELECT
    Customer_id,
    COUNT(*) AS Frequency
FROM
    ORDERS_INFO
GROUP BY
    Customer_id;

-- CALCULATE MONETARY
SELECT TOP 10
    Customer_id,
    SUM(NEW_AMOUNT) AS Monetary
FROM
    ORDERS_INFO
GROUP BY
    Customer_id
    ORDER BY SUM(NEW_AMOUNT) DESC;



--Find out the number of customers who purchased in all the channels and find the key metrics.
SELECT
    COUNT(Customer_id) AS COUNTS
FROM
    ORDERS_INFO
GROUP BY
    Customer_id
HAVING
    COUNT(DISTINCT Channel) = (SELECT COUNT(DISTINCT Channel) FROM ORDERS_INFO);

 --Understand the behavior of one time buyers and repeat buyers   
SELECT
    Customer_id,
    DATEDIFF(day, MIN(BILL_DATE_TIMESTAMP), MAX(BILL_DATE_TIMESTAMP))
 AS Recency,
    COUNT(*) AS Frequency,
    SUM(NEW_AMOUNT) AS Total_Spent
FROM
    ORDERS_INFO
WHERE
    Customer_id IN (
        SELECT
            Customer_id
        FROM
            ORDERS_INFO
        GROUP BY
            Customer_id
        HAVING
            COUNT(DISTINCT Channel) = (SELECT COUNT(DISTINCT Channel) FROM ORDERS_INFO)
    )
GROUP BY
    Customer_id;

--Understand the behavior of discount seekers & non discount seekers

SELECT
    Customer_id,
    CASE
        WHEN AVG(Discount) > 0 THEN 'Discount Seeker'
        ELSE 'Non-Discount Seeker'
    END AS Customer_Type,
    COUNT(*) AS Number_of_Orders,
    SUM(NEW_AMOUNT) AS Total_Spent,
    AVG(Cost_Per_Unit) AS Avg_Cost_Per_Unit,
    AVG(MRP) AS Avg_MRP
FROM
    ORDERS_INFO
GROUP BY
    Customer_id;
    
-- CUSTOMER_TYPE , NO OF CUSTOMER , TOTAL_SPEND , AVG_SPEND
SELECT
    Customer_Type,
    COUNT(*) AS Number_of_Customers,
    AVG(Number_of_Orders) AS Avg_Number_of_Orders,
    AVG(Total_Spent) AS Avg_Total_Spent,
    AVG(Avg_Cost_Per_Unit) AS Avg_Avg_Cost_Per_Unit,
    AVG(Avg_MRP) AS Avg_Avg_MRP
FROM (
    SELECT
        Customer_id,
        CASE
            WHEN AVG(Discount) > 0 THEN 'Discount Seeker'
            ELSE 'Non-Discount Seeker'
        END AS Customer_Type,
        COUNT(*) AS Number_of_Orders,
        SUM(NEW_AMOUNT) AS Total_Spent,
        AVG(Cost_Per_Unit) AS Avg_Cost_Per_Unit,
        AVG(MRP) AS Avg_MRP
    FROM
        ORDERS_INFO
    GROUP BY
        Customer_id
) AS Customer_Segmentation
GROUP BY
    Customer_Type;


--Understand preferences of customers (preferred channel, Preferred payment method, preferred store, discount preference, preferred categories etc.)

--PREFERED CHANNEL
SELECT
    Customer_id,
    Channel AS Preferred_Channel,
    COUNT(*) AS Number_of_Orders
FROM
    ORDERS_INFO
GROUP BY
    Customer_id, Channel
ORDER BY
    Customer_id, Number_of_Orders DESC;

--PREFERED PAYMENT METHOD
WITH CTE1 AS (
SELECT
    payment_type AS Preferred_Payment_Method,
    COUNT(*) AS Number_of_Orders
    FROM 
    ORDERS_INFO
GROUP BY
  payment_type
ORDER BY
    Number_of_Orders DESC) 
    SELECT * FROM CTE1

--PREFERED CATEGORY

SELECT
TOP 5
    Category AS Preferred_Category,
    COUNT(CUSTOMER_ID) AS Number_of_Orders
FROM
    ORDERS_INFO
GROUP BY Category
ORDER BY
    Number_of_Orders DESC;

--PREFEREED STORE
SELECT TOP 5
    Delivered_StoreID AS Preferred_Store,
    COUNT(CUSTOMER_ID) AS Number_of_CUST
FROM
    ORDERS_INFO
GROUP BY
 Delivered_StoreID
ORDER BY
 Number_of_CUST DESC;

--Analyze Customer Behavior by Category Purchasing
WITH CTE1 AS (
SELECT
    Customer_id,
    Purchasing_Behavior,
    COUNT(*) AS Number_of_Orders,
    SUM(NEW_Amount) AS Total_Spent
FROM (
    SELECT
        Customer_id,
        NEW_AMOUNT,
        CASE
            WHEN COUNT(DISTINCT Category) OVER (PARTITION BY Customer_id) = 1 THEN 'Single Category Purchaser'
            ELSE 'Multiple Categories Purchaser'
        END AS Purchasing_Behavior
    FROM
        ORDERS_INFO
) AS SubQuery
GROUP BY
    Customer_id,
    Purchasing_Behavior
ORDER BY
    Customer_id
) 
SELECT Purchasing_Behavior, COUNT(CUSTOMER_ID) AS CUSTOMER_COUNT FROM CTE1
GROUP BY Purchasing_Behavior

--GENDER PEREFERED CATEGORY
SELECT GENDER , COUNT(ORDER_ID) AS TOTAL_ORDERS FROM CUSTOMER AS C
INNER JOIN ORDERS_INFO AS I
ON C.CUSTID = I.CUSTOMER_ID
GROUP BY GENDER


SELECT 
    a.order_id, 
    a.product_id AS product_A, 
    b.product_id AS product_B
FROM ORDERS_INFO a
JOIN ORDERS_INFO b 
ON a.order_id = b.order_id 
AND a.product_id < b.product_id;

SELECT 
    product_A, 
    product_B, 
    COUNT(*) AS frequency
FROM (
    SELECT 
        a.order_id, 
        a.product_id AS product_A, 
        b.product_id AS product_B
    FROM orders_INFO a
    JOIN orders_INFO b 
    ON a.order_id = b.order_id 
    AND a.product_id < b.product_id
) AS product_pairs
GROUP BY 
    product_A, 
    product_B
ORDER BY 
    frequency DESC;

-- Calculate Support for Product Pairs
WITH product_pair_support AS (
    SELECT 
        product_A, 
        product_B, 
        COUNT(*) AS pair_count
    FROM (
        SELECT 
            a.order_id, 
            a.product_id AS product_A, 
            b.product_id AS product_B
        FROM orders_INFO a
        JOIN orders_INFO b 
        ON a.order_id = b.order_id 
        AND a.product_id < b.product_id
    ) AS product_pairs
    GROUP BY 
        product_A, 
        product_B
),

total_orders AS (
    SELECT 
        COUNT(DISTINCT order_id) AS total_orders
    FROM orders_INFO
),

product_support_metrics AS (
    SELECT 
        ps.product_A, 
        ps.product_B, 
        ps.pair_count,
        (ps.pair_count::float / total_orders) AS support,
        (ps.pair_count::float / (SELECT COUNT(*) FROM orders_INFO WHERE product_id = ps.product_A)) AS confidence_A_to_B,
        (ps.pair_count::float / (SELECT COUNT(*) FROM orders_INFO WHERE product_id = ps.product_B)) AS confidence_B_to_A
    FROM product_pair_support ps, total_orders 
)

SELECT 
    product_A, 
    product_B, 
    pair_count, 
    support, 
    confidence_A_to_B, 
    confidence_B_to_A, 
    (support / ((SELECT COUNT(*) FROM orders_INFO WHERE product_id = product_A) / total_orders.total_orders)) AS lift_A_to_B,
    (support / ((SELECT COUNT(*) FROM orders_INFO WHERE product_id = product_B) / total_orders.total_orders)) AS lift_B_to_A
FROM product_support_metrics, total_orders
ORDER BY support DESC;


--
WITH product_pairs AS (
    SELECT
        o1.product_id AS product_id_1,
        o2.product_id AS product_id_2,
        COUNT(DISTINCT o1.order_id) AS num_orders
    FROM
        orders_info o1
    JOIN
        orders_info o2 ON o1.order_id = o2.order_id AND o1.product_id < o2.product_id
    GROUP BY
        o1.product_id, o2.product_id
),
ranked_product_pairs AS (
    SELECT
        product_id_1,
        product_id_2,
        num_orders,
        ROW_NUMBER() OVER (PARTITION BY product_id_1 ORDER BY num_orders DESC) AS pair_rank
    FROM
        product_pairs
)
SELECT
    pp.product_id_1,
    pp.product_id_2,
    pp.num_orders
FROM
    ranked_product_pairs pp
JOIN
    PRODUCTSINFO p1 ON pp.product_id_1 = p1.product_id
JOIN
    PRODUCTSINFO p2 ON pp.product_id_2 = p2.product_id
WHERE
    pair_rank = 1 -- Get the top pair for each product_id_1
ORDER BY
    pp.num_orders DESC;

--Total Sales & Percentage of sales by category
SELECT
    Category,
    SUM(NEW_AMOUNT) AS Total_Sales,
    SUM(NEW_AMOUNT) / (SELECT SUM(NEW_AMOUNT)FROM ORDERS_INFO) * 100 AS Percentage_of_Sales
FROM
    ORDERS_INFO
GROUP BY
    Category
ORDER BY
    Total_Sales DESC;


--

SELECT
    YEAR(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP))) AS Years,
    MONTH(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP))) AS Months,
    Category,
    COUNT(CASE WHEN Category IS NOT NULL THEN order_id END) AS Orders_with_Category,
    COUNT(order_id) AS Total_Orders,
    COUNT(CASE WHEN Category IS NOT NULL THEN order_id END) / COUNT(order_id) AS Category_Penetration
FROM
    ORDERS_INFO
GROUP BY
    YEAR(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP))),
    MONTH(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP))),
    Category
ORDER BY
    Years, Months, Category;
select distinct category from orders_info


SELECT
    Years,
    Months,
    
    SUM(CASE WHEN Category = 'Toys & Gifts' THEN Total_Orders ELSE 0 END) AS ToysGifts_Total_Orders,
    SUM(CASE WHEN Category = 'Toys & Gifts' THEN Category_Penetration ELSE 0 END) AS ToysGifts_Penetration,
    SUM(CASE WHEN Category = 'Stationery' THEN Total_Orders ELSE 0 END) AS Category2_Total_Orders,
    SUM(CASE WHEN Category = 'Stationery' THEN Category_Penetration ELSE 0 END) AS Category2_Penetration
    -- Add more columns as needed for other categories
FROM (
    SELECT
        YEAR(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP))) AS Years,
         MONTH(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP))) as months,
        Category,
        COUNT(CASE WHEN Category IS NOT NULL THEN order_id END) AS Orders_with_Category,
        COUNT(order_id) AS Total_Orders,
        COUNT(CASE WHEN Category IS NOT NULL THEN order_id END) / COUNT(order_id) AS Category_Penetration
    FROM
        ORDERS_INFO
    GROUP BY
        YEAR(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP))) ,
         MONTH(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP))),
        Category
) AS PivotData
GROUP BY
    Years, Months
ORDER BY
    Years desc, Months desc;
=
--CATEGORIES SALING TOGETHER

CREATE OR REPLACE VIEW OrderCategories AS
SELECT
    A.ORDER_ID,
    P.Category
FROM ORDERS A
JOIN RETAIL_ANALYSIS.PUBLIC.PRODUCTSINFO P ON A.PRODUCT_ID = P.PRODUCT_ID;

SELECT
    oc1.Category AS Category1,
    oc2.Category AS Category2,
    COUNT(*) AS TogetherCount
FROM OrderCategories oc1
JOIN OrderCategories oc2 
    ON oc1.ORDER_ID = oc2.ORDER_ID 
    AND oc1.Category < oc2.Category
GROUP BY oc1.Category, oc2.Category
ORDER BY TogetherCount DESC;

--Which categories (top 10) are maximum rated & minimum rated and average rating score? 
WITH MaxRatedCategories AS (
    SELECT
        Category,
        AVG(Customer_Satisfaction_Score) AS Average_Rating
    FROM
        ORDERS_INFO
    GROUP BY
        Category
    ORDER BY
        Average_Rating DESC
    LIMIT 10
),
MinRatedCategories AS (
    SELECT
        Category,
        AVG(Customer_Satisfaction_Score) AS Average_Rating
    FROM
        ORDERS_INFO
    GROUP BY
        Category
    ORDER BY
        Average_Rating ASC
    LIMIT 10
)
SELECT
    'Max Rated' AS Rating_Type,
    Category,
    Average_Rating
FROM
    MaxRatedCategories

UNION ALL

SELECT
    'Min Rated' AS Rating_Type,
    Category,
    Average_Rating
FROM
    MinRatedCategories;

--avg rated
SELECT
    Category,
    AVG(Customer_Satisfaction_Score) AS Average_Rating
FROM
    ORDERS_INFO
GROUP BY
    Category
ORDER BY
    Average_Rating DESC;

select * from customer


SELECT DISTINCT STOREID FROM STORE_INFO
SELECT DISTINCT DELIVERED_STOREID FROM ORDERS_INFO
--average rating by loaction present in customer table
SELECT TOP 5
    c.customer_state AS Location,
    AVG(o.Customer_Satisfaction_Score) AS Average_Rating
FROM
    ORDERS_INFO o
JOIN
    CUSTOMER c ON o.Customer_id = c.CUSTID
GROUP BY
    c.customer_state
ORDER BY
    Average_Rating DESC;

--average rating by loaction present in store table 
select * from store_info

SELECT TOP 5
    s.seller_state AS Location,
    AVG(o.Customer_Satisfaction_Score) AS Average_Rating
FROM
    ORDERS_INFO o
JOIN
    STORE_INFO s ON o.Delivered_StoreID = s.StoreID
GROUP BY
    s.seller_state
ORDER BY
    Average_Rating DESC;


----------------------------------------------COMBINE ANALYSIS--------------------------------------------------------
--Average rating by location, store, product, category, month, etc.

WITH AvgRatingByLocation AS (
    SELECT
    c.customer_state AS Dimension_Value,
    AVG(o.Customer_Satisfaction_Score) AS Average_Rating
FROM
    ORDERS_INFO o
JOIN
    CUSTOMER c ON o.Customer_id = c.CUSTID
GROUP BY
    c.customer_state
ORDER BY
    Average_Rating DESC

),
AvgRatingByStore AS (
    SELECT
        delivered_storeid AS Dimension_Value,
        AVG(Customer_Satisfaction_Score) AS Average_Rating
    FROM
        ORDERS_INFO
    GROUP BY
        delivered_storeid
),
AvgRatingByProduct AS (
    SELECT
        product_id AS Dimension_Value,
        AVG(Customer_Satisfaction_Score) AS Average_Rating
    FROM
        ORDERS_INFO
    GROUP BY
        product_id
),
AvgRatingByCategory AS (
    SELECT
        Category AS Dimension_Value,
        AVG(Customer_Satisfaction_Score) AS Average_Rating
    FROM
        ORDERS_INFO
    GROUP BY
        Category
),
AvgRatingByMonth AS (
    SELECT
        CONCAT(YEAR(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP))),month(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP)))) AS Dimension_Value,
        AVG(Customer_Satisfaction_Score) AS Average_Rating
    FROM
        ORDERS_INFO
    GROUP BY
        YEAR(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP))), month(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP)))
)

SELECT
    'Location' AS Dimension_Type,
    Dimension_Value,
    Average_Rating
FROM
    AvgRatingByLocation

UNION ALL

SELECT
    'Store' AS Dimension_Type,
    Dimension_Value,
    Average_Rating
FROM
    AvgRatingByStore

UNION ALL

SELECT
    'Product' AS Dimension_Type,
    Dimension_Value,
    Average_Rating
FROM
    AvgRatingByProduct

UNION ALL

SELECT
    'Category' AS Dimension_Type,
    Dimension_Value,
    Average_Rating
FROM
    AvgRatingByCategory

UNION ALL

SELECT
    'Month' AS Dimension_Type,
    Dimension_Value,
    Average_Rating
FROM
    AvgRatingByMonth;

----------------------------------------------------------------------------------------------------------------------
WITH order_products AS (
    SELECT distinct
        ORDER_ID,
        PRODUCT_ID
    FROM orders
),
product_pairs AS (
    SELECT
        op1.PRODUCT_ID AS product1,
        op2.PRODUCT_ID AS product2,
        COUNT(*) AS count_together
    FROM order_products op1
    JOIN order_products op2 ON op1.ORDER_ID = op2.ORDER_ID AND op1.PRODUCT_ID < op2.PRODUCT_ID
    GROUP BY product1, product2
),
product_counts AS (
    SELECT
        PRODUCT_ID,
        COUNT(DISTINCT ORDER_ID) AS order_count
    FROM order_products
    GROUP BY PRODUCT_ID
)
SELECT
    pp.product1,
    pp.product2,
    pp.count_together,
    pc1.order_count AS product1_order_count,
    pc2.order_count AS product2_order_count,
    pp.count_together / pc1.order_count AS confidence_product1_to_product2,
    pp.count_together / pc2.order_count AS confidence_product2_to_product1,
    pp.count_together / (pc1.order_count * pc2.order_count) AS lift
FROM product_pairs pp
JOIN product_counts pc1 ON pp.product1 = pc1.PRODUCT_ID
JOIN product_counts pc2 ON pp.product2 = pc2.PRODUCT_ID
ORDER BY pp.count_together DESC
LIMIT 100;


---------------------------------------------------TIME ANALYSIS-------------------------------------------------------
-- Months with Highest and Least Sales, Sales Amount, and Contribution Percentage
--highest sale
SELECT
    YEAR(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP))) AS YEARS,
    month(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP))) AS Month,
    SUM(NEW_AMOUNT) AS Sales_Amount,
    SUM(NEW_AMOUNT) * 100.0 / SUM(SUM(NEW_AMOUNT)) OVER () AS Contribution_Percentage
FROM
    ORDERS_INFO
GROUP BY
    YEARS,Month
ORDER BY
    Sales_Amount DESC
LIMIT 1;
--least month with sales
SELECT
    YEAR(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP))) AS YEARS,
    month(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP))) AS MonthS,
    SUM(NEW_AMOUNT) AS Sales_Amount,
    SUM(NEW_AMOUNT) * 100.0 / SUM(SUM(NEW_AMOUNT)) OVER () AS Contribution_Percentage
FROM
    ORDERS_INFO
GROUP BY
YEARS,
    MonthS
    
ORDER BY
    Sales_Amount ASC
LIMIT 1;

--Sales Trend by Month
SELECT TOP 3
    month(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP))) AS Month,
    SUM(NEW_AMOUNT) AS Sales_Amount
FROM
    ORDERS_INFO
GROUP BY
    Month
ORDER BY
    SALES_AMOUNT DESC;

--Weekdays vs. Weekends:

SELECT
    CASE
        WHEN EXTRACT(DOW FROM TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP))) IN (1, 2, 3, 4, 5) THEN 'Weekday'
        ELSE 'Weekend'
    END AS Day_Type,
    SUM(NEW_AMOUNT) AS Sales_Amount
FROM
    ORDERS_INFO
GROUP BY
    Day_Type
ORDER BY
    Sales_Amount DESC;



--QUATERLY SALES ANALYSIS
SELECT
    DATE_TRUNC('quarter', TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP))) AS Quarter,
    SUM(NEW_AMOUNT) AS Sales_Amount
FROM
    ORDERS_INFO
GROUP BY
    Quarter
ORDER BY
    Quarter;

--MONTHLY SALES ANALYSIS
SELECT
    DATE_TRUNC('month',TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP))) AS Month,
    SUM(NEW_AMOUNT) AS Sales_Amount
FROM
    ORDERS_INFO
GROUP BY
    Month
ORDER BY
    Month;


--WEEK SALES ANALYSIS
SELECT
    DATE_TRUNC('week',TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP))) AS Week,
    SUM(NEW_AMOUNT) AS Sales_Amount
FROM
    ORDERS_INFO
GROUP BY
    Week
ORDER BY
    Week;

-- SALES BY DAYS OF WEEK
SELECT
    EXTRACT(DOW FROM TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP))) AS Day_Of_Week,
    SUM(NEW_AMOUNT) AS Sales_Amount
FROM
    ORDERS_INFO
GROUP BY
    Day_Of_Week
ORDER BY
    Day_Of_Week


select max(bill_date_timestamp) from orders_info
------------------------------------------------RFM ANALYSIS--------------------------------------------------------

create or replace table rfm as
WITH customer_rfm AS (
    SELECT
        A.Customer_id,
        DATEDIFF('days', '2023-09-18 21:10:00.000', MAX(A.Bill_date_timestamp)) AS recency,
        COUNT(DISTINCT A.ORDER_ID) AS frequency,
        SUM(A.NEW_AMOUNT) AS monetary_value
    FROM ADJUSTEDORDERSTABLE AS A
    GROUP BY A.Customer_id
),

rfm_scores AS (
    SELECT
        CR.Customer_id,
        CR.recency,
        CR.frequency,
        CR.monetary_value,
        NTILE(4) OVER (ORDER BY CR.recency) AS r_score, -- 1 for most recent
        NTILE(4) OVER (ORDER BY CR.frequency DESC) AS f_score, -- 1 for most frequent
        NTILE(4) OVER (ORDER BY CR.monetary_value DESC) AS m_score, -- 1 for highest spending
        (NTILE(4) OVER (ORDER BY CR.recency) + 
         NTILE(4) OVER (ORDER BY CR.frequency DESC) + 
         NTILE(4) OVER (ORDER BY CR.monetary_value DESC)) AS rfm_sum
    FROM customer_rfm CR
)
SELECT
    RS.Customer_id,
    RS.recency,
    RS.frequency,
    RS.monetary_value,
    RS.r_score,
    RS.f_score,
    RS.m_score,
    RS.rfm_sum,
    CASE
        WHEN RS.rfm_sum <= 3 THEN 'Platinum'
        WHEN RS.rfm_sum <= 6 THEN 'Gold'
        WHEN RS.rfm_sum <= 9 THEN 'Silver'
        ELSE 'Standard'
    END AS customer_segment
FROM rfm_scores RS
ORDER BY RS.rfm_sum, RS.Customer_id;

CUSTOMER_SEGMENT	CUSTOMERS
Platinum	42
Gold	36805
Silver	37504
Standard	24221

---------------------------------------------------category anaysis-------------------------------------------------

-- Total Sales & Percentage of Sales by Category (Pareto Analysis)
SELECT
    Category,
    SUM(NEW_AMOUNT) AS Total_Sales,
    ROUND(SUM(NEW_AMOUNT) * 100.0 / (SELECT SUM(NEW_AMOUNT) FROM orders_info), 2) AS Percentage_of_Sales
FROM
    orders_info
GROUP BY
    Category
ORDER BY
    Total_Sales DESC;

--Customer Satisfaction Analysis by Category:    
SELECT TOP 5
    P.Category,
    AVG(R.Customer_Satisfaction_Score) AS avg_customer_satisfaction
FROM ADJUSTEDORDERSTABLE AS A
LEFT JOIN ORDERREVIEW_RATINGS AS R ON A.ORDER_ID = R.ORDER_ID
LEFT JOIN RETAIL_ANALYSIS.PUBLIC.PRODUCTSINFO AS P ON A.PRODUCT_ID = P.PRODUCT_ID
GROUP BY P.Category
ORDER BY P.Category, avg_customer_satisfaction DESC;

--Product Attributes Analysis by Category:

SELECT TOP 5
    P.Category,
    AVG(P.product_weight_g) AS avg_product_weight,
    AVG(P.product_length_cm) AS avg_product_length_cm,
    AVG(P.product_height_cm) AS avg_product_height_cm,
    AVG(P.product_width_cm) AS avg_product_width_cm
FROM RETAIL_ANALYSIS.PUBLIC.PRODUCTSINFO AS P
GROUP BY P.Category;

--Customer Behavior Analysis:
SELECT TOP 5
    P.Category,
    COUNT(DISTINCT A.ORDER_ID) AS total_orders,
    SUM(A.NEW_AMOUNT) AS total_sales_amount,
    AVG(A.NEW_AMOUNT) AS avg_order_size
FROM ADJUSTEDORDERSTABLE AS A
LEFT JOIN RETAIL_ANALYSIS.PUBLIC.PRODUCTSINFO AS P ON A.PRODUCT_ID = P.PRODUCT_ID
GROUP BY P.Category;


--Seasonal Trends Analysis:
SELECT
    P.Category,
    TO_VARCHAR(TO_DATE(TO_TIMESTAMP(BILL_DATE_TIMESTAMP)), 'YYYY-MM') AS month_year,
    SUM(A.NEW_AMOUNT) AS monthly_sales_amount
FROM ADJUSTEDORDERSTABLE AS A
LEFT JOIN RETAIL_ANALYSIS.PUBLIC.PRODUCTSINFO AS P ON A.PRODUCT_ID = P.PRODUCT_ID
GROUP BY P.Category, month_year
ORDER BY MONTHLY_SALES_AMOUNT ;

--Customer Segment Analysis:
CREATE VIEW CUSTOMER_SEGMENT AS 
SELECT
    CUSTOMER_ID,
    AVG(NEW_AMOUNT) AS avg_purchase_amount,
     CASE
        WHEN AVG(NEW_AMOUNT) > 5000 THEN 'HIGH VALUE'
        WHEN AVG(NEW_AMOUNT) > 1000THEN 'MID VALUE'
        ELSE 'LOW VALUE'
    END AS customer_segment,
    FROM ORDERS_INFO
GROUP BY CUSTOMER_ID
ORDER BY AVG_PURCHASE_AMOUNT DESC

SELECT CUSTOMER_SEGMENT, COUNT(CUSTOMER_ID) AS NO_OF_CUST FROM CUSTOMER_SEGMENT GROUP BY CUSTOMER_SEGMENT

SELECT CATEGORY , AVG(NEW_AMOUNT) AS SUMS FROM ORDERS_INFO GROUP BY CATEGORY ORDER BY SUMS DESC

--. Perform cohort analysis (customer retention for month on month and retention for fixed month)

WITH first_purchase AS (
    SELECT 
        Customer_id, 
        MIN(DATEPART(month, Bill_date_timestamp)) AS first_purchase_month,
        MIN(YEAR(Bill_date_timestamp)) AS first_purchase_year
    FROM 
        orders
    GROUP BY 
        customer_id
)
SELECT 
    customer_id, 
    first_purchase_month,
    first_purchase_year
FROM 
    first_purchase;
	

--Total Sales & Percentage of sales by category (Perform Pareto Analysis)
select distinct category,sum(o.Total_Amount) as total_sales, 
                (sum(o.Total_Amount) /(select sum(total_amount) from orders))*100 as perc
from orders as o join product_info as p
on o.product_id=p.product_id
group by Category
order by perc desc