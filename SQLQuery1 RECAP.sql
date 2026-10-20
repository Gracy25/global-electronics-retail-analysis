-- =====================================================
-- 1. DATA QUALITY AND DATE COVERAGE
-- =====================================================
-- a. Customers

SELECT COUNT(*) AS MissingCustomers
FROM dbo.Sales s
LEFT JOIN dbo.Customers c
    ON s.CustomerKey = c.CustomerKey
WHERE c.CustomerKey IS NULL;

--b. Products

SELECT COUNT(*) AS MissingProducts
FROM dbo.Sales s
LEFT JOIN dbo.Products p
    ON s.ProductKey = p.ProductKey
WHERE p.ProductKey IS NULL;

--c. Stores

SELECT COUNT(*) AS MissingStores
FROM dbo.Sales s
LEFT JOIN dbo.Stores st
    ON s.StoreKey = st.StoreKey
WHERE st.StoreKey IS NULL;


-- =====================================================
-- DATA QUALITY CHECK: DATE COVERAGE
-- =====================================================

-- Business Question:
-- Does the dataset contain a complete year of sales data?

SELECT
    MIN(Order_Date) AS Earliest_Order_Date,
    MAX(Order_Date) AS Latest_Order_Date
FROM dbo.Sales;

--When year is 2021

SELECT
    MIN(Order_Date) AS First_2021_Order,
    MAX(Order_Date) AS Last_2021_order,
    COUNT(DISTINCT Order_Number) AS Orders_2021
FROM dbo.Sales
WHERE YEAR(Order_Date) = 2021;


-- Finding:
-- The dataset ends in February 2021.
-- Therefore, 2021 contains only partial-year data.

-- Important:
-- 2021 should not be directly compared with the full-year
-- results from 2016-2020.




-- =====================================================
-- 2. SALES PERFORMANCE OVER TIME
-- =====================================================
-- 2.1 REVENUE ANALYSIS
-- =====================================================
--How much revenue did the business generate each year?

SELECT
    YEAR(s.Order_Date) AS SalesYear,
    SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue_USD
FROM dbo.Sales s
INNER JOIN dbo.Products p
    ON s.ProductKey = p.ProductKey
GROUP BY YEAR(s.Order_Date)
ORDER BY SalesYear;

-- Finding:
-- Revenue increased consistently from 2016 to 2019,
-- reaching approximately $18.26M in 2019.
-- Revenue then declined sharply to approximately $9.29M in 2020,
-- before recovering slightly to $10.39M in 2021.

-- Business Insight:
-- The business experienced strong revenue growth through 2019,
-- followed by a major decline in 2020. Although revenue recovered
-- slightly in 2021, it remained well below the 2019 peak.

-- Business Question:
-- Did the number of units sold also fall significantly in 2020?

SELECT
    YEAR(s.Order_Date) AS SalesYear,
    SUM(s.Quantity) AS unit_sold
FROM dbo.Sales s
GROUP BY YEAR(s.Order_Date)
ORDER BY SalesYear;

-- Finding:
-- Units sold increased substantially from 2016 to 2019,
-- reaching a peak of 68,440 units in 2019.
-- Units sold then fell to 34,463 in 2020.

-- 2021 is descibed as partial year figure with 3,797 units sold since 
-- it contain just January and Febuarary order date
-- and should not be compared with full-report of 2016-2020 

--Did the number of order also decline

SELECT
    YEAR(s.Order_Date) AS SalesYear,
    COUNT(DISTINCT s.Order_Number) AS Total_Orders
FROM dbo.Sales s
GROUP BY YEAR(s.Order_Date)
ORDER BY SalesYear;

--AVERAGE REVENUE PER ORDER
SELECT
    YEAR(s.Order_Date) AS SalesYear,
    SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue_USD,
    COUNT(DISTINCT s.Order_Number) AS Total_Orders,
    1.0 * SUM(s.Quantity * p.Unit_Price_USD_Num) /  COUNT(DISTINCT s.Order_Number) AS Average_order_value
FROM dbo.Sales s
INNER JOIN dbo.Products p
    ON s.ProductKey = p.ProductKey
GROUP BY YEAR(s.Order_Date)
ORDER BY SalesYear;
-- Finding:
-- Average order value declined from approximately $2,425 in 2016
-- to approximately $2,011 in 2019.
-- It remained relatively stable in 2020 and increased slightly
-- to approximately $2,087 in 2021.
--
-- Insight:
-- The sharp decline in 2020-2021 revenue was primarily associated
-- with a decline in the number of orders and units sold rather
-- than a major change in average order value.


SELECT
    YEAR(s.Order_Date) AS SalesYear,
    MONTH(s.Order_Date) AS SalesMonth,
    COUNT(DISTINCT s.Order_Number) AS Total_Orders
FROM dbo.Sales s
GROUP BY YEAR(s.Order_Date), MONTH(s.Order_Date)
ORDER BY SalesYear,  SalesMonth;

-- Important Data Quality Finding:
-- The 2021 data only contains January and February.
-- Therefore, 2021 should NOT be directly compared with the
-- full-year results from 2016-2020.

-- The apparent decline in 2021 revenue, orders and units sold
-- is largely explained by incomplete year coverage and should not be interpreted as 
--a full-year business decline


    -- =====================================================
-- 3. GEOGRAPHIC PERFORMANCE.
-- =====================================================

SELECT
    YEAR(s.Order_Date) AS SalesYear,
    c.Country,
    SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue_Generated
FROM dbo.Customers c
INNER JOIN dbo.Sales s
   ON c.CustomerKey = s.CustomerKey
INNER JOIN dbo.Products p
    ON s.ProductKey = p.ProductKey
GROUP BY
    c.Country,
    YEAR(s.Order_Date)
ORDER BY 
    Revenue_generated DESC;

    -- Finding:
-- The United States is the company's dominant revenue market.
-- Revenue in the U.S. increased substantially from 2016 to 2019,
-- reaching approximately $10.13M in 2019.
--
-- In 2020, revenue declined substantially across the major markets.
-- The United States declined from approximately $10.13M in 2019
-- to $5.27M in 2020, while the UK, Germany and Canada also
-- experienced significant declines.
--
-- Insight:
-- The 2020 revenue decline appears to be broad-based rather than
-- being driven by a single country.
--
-- Data Quality Note:
-- 2021 contains only January-February and should not be compared
-- directly with full-year results.



-- =====================================================
-- 4. PRODUCT AND BRAND PROFITABILITY
-- =====================================================
SELECT
    p.Category,
    SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue_Generated
FROM dbo.Products p
INNER JOIN dbo.Sales s
    ON p.ProductKey = s.ProductKey
GROUP BY
    p.Category
ORDER BY
    Revenue_Generated DESC;

--Computers are the clear revenue leader at about $19.30M.

--Which product categories generate the most profit?
SELECT
    p.Category,
    SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num) ) AS Total_profit
FROM dbo.Products p
INNER JOIN dbo.Sales s
    ON p.ProductKey = s.ProductKey
GROUP BY 
    p.Category
ORDER BY
    Total_profit DESC;

--Computers are the strongest category in absolute profit, generating about $11.28M, 
--substantially more than any other category.

--Which product categories have the highest profit margins?

SELECT
    p.Category,
    SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num) ) AS Total_profit,
    CAST(
    100.0 * SUM(
        s.Quantity *
        (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)
    )
    / NULLIF(
        SUM(s.Quantity * p.Unit_Price_USD_Num),
        0
    )
    AS DECIMAL(10,2)
) AS Profit_Margin
FROM dbo.Products p
INNER JOIN dbo.Sales s
    ON p.ProductKey = s.ProductKey
GROUP BY 
    p.Category
ORDER BY
    Profit_Margin DESC;

-- Finding:
-- Computers generate the highest total profit at approximately $11.28M.
-- However, Music, Movies and Audio Books have the highest profit margin
-- at approximately 60.98%.

-- Insight:
-- The category with the highest total profit is not the same as the
-- category with the highest profit margin.
-- Computers provide the greatest absolute profit contribution,
-- while Music, Movies and Audio Books generate the strongest margin.

-- Business implication:
-- Management should consider both sales scale and profitability when
-- evaluating category performance rather than relying on revenue alone.


SELECT
    p.Category,
    p.Product_Name,
    SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num) ) AS Total_profit,
    CAST(
    100.0 * SUM(
        s.Quantity *
        (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)
    )
    / NULLIF(
        SUM(s.Quantity * p.Unit_Price_USD_Num),
        0
    )
    AS DECIMAL(10,2)
) AS Profit_Margin
FROM dbo.Products p
INNER JOIN dbo.Sales s
    ON p.ProductKey = s.ProductKey
GROUP BY 
    p.Product_Name,
    p.Category
ORDER BY
    Total_profit DESC;

--Are the top-profit products selling a lot of units,
--or are they simply high-margin products?

SELECT
    p.Category,
    p.Product_Name,
    SUM(s.Quantity) AS Unit_Sold,
    SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num) ) AS Total_profit,
  CAST(
    100.0 * SUM(
        s.Quantity *
        (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)
    )
    / NULLIF(
        SUM(s.Quantity * p.Unit_Price_USD_Num),
        0
    )
    AS DECIMAL(10,2)
) AS Profit_Margin
FROM dbo.Products p
INNER JOIN dbo.Sales s
    ON p.ProductKey = s.ProductKey
GROUP BY 
    p.Product_Name,
    p.Category
ORDER BY
    Total_profit DESC;

    --Which brands are driving the company's sales and profitability?

SELECT  
    p.Brand,
    SUM(s.Quantity) AS Unit_Sold,
    SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num) ) AS Total_profit,
   CAST(
    100.0 * SUM(
        s.Quantity *
        (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)
    )
    / NULLIF(
        SUM(s.Quantity * p.Unit_Price_USD_Num),
        0
    )
    AS DECIMAL(10,2)
) AS Profit_Margin 
FROM dbo.Products p
INNER JOIN dbo.Sales s
    ON p.ProductKey = s.ProductKey
GROUP BY 
   p.Brand
ORDER BY
    Total_profit DESC;

    -- Finding:
-- Adventure Works generates the highest total profit among brands.
-- Proseware has the highest profit margin.
--
-- Insight:
-- The brand with the highest absolute profit is different from
-- the brand with the highest profit margin.
-- Adventure Works appears to be the stronger brand by profit scale,
-- while Proseware demonstrates stronger profitability efficiency.
--
-- Business implication:
-- Management should evaluate both profit contribution and profit margin
-- when assessing brand performance.



-- =====================================================
-- 5. STORE, LOCATION, AND CHANNEL PERFORMANCE
-- =====================================================

-- =====================================================
-- 5.1 STORE PERFORMANCE
-- =====================================================
SELECT TOP 10
*
FROM dbo.Stores;

SELECT
    st.Storekey,
    st.Country,
    st.State,
    SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num) ) AS Total_profit
FROM dbo.Stores st
INNER JOIN dbo.Sales s
    ON st.StoreKey = s.StoreKey
INNER JOIN dbo.Products p
    ON s.Productkey = p.ProductKey
GROUP BY
    st.StoreKey,
    st.Country,
    st.State
ORDER BY
    Total_profit DESC;


--The online channel is the company's strongest individual sales location, 
--generating substantially more revenue and profit than any physical store.

--But dont compare online store with physical stores, instead lets ask the following question

--1. Among physical stores, which locations perform best?
--2. How important is the online channel compared with all physical stores combined?

--Number 1 can be achived by excluding the online store

SELECT
    st.Storekey,
    st.Country,
    st.State,
    SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num) ) AS Total_profit
FROM dbo.Stores st
INNER JOIN dbo.Sales s
    ON st.StoreKey = s.StoreKey
INNER JOIN dbo.Products p
    ON s.Productkey = p.ProductKey
WHERE st.StoreKey <> 0
GROUP BY
    st.StoreKey,
    st.Country,
    st.State
ORDER BY
    Total_profit DESC;

--Does store size have a relationship with revenue and profit?

SELECT
    st.Storekey,
    st.Square_Meters,
    st.Country,
    st.State,
    SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num) ) AS Total_profit
FROM dbo.Stores st
INNER JOIN dbo.Sales s
    ON st.StoreKey = s.StoreKey
INNER JOIN dbo.Products p
    ON s.Productkey = p.ProductKey
WHERE st.StoreKey <> 0
GROUP BY
    st.StoreKey,
    st.Country,
    st.State,
    st.Square_Meters
ORDER BY
    Total_profit DESC;


--Which physical stores generate the most profit per square meter?

SELECT
    st.StoreKey,
    st.Square_Meters,
    st.Country,
    st.State,

    SUM(
        s.Quantity * p.Unit_Price_USD_Num
    ) AS Revenue,

    SUM(
        s.Quantity *
        (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)
    ) AS Total_Profit,

   CAST(
    CAST(
        SUM(
            s.Quantity *
            (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)
        ) AS DECIMAL(18,2)
    )
    / NULLIF(
        CAST(st.Square_Meters AS DECIMAL(18,2)),
        0
    )
    AS DECIMAL(18,2)
) AS Profit_Per_Square_Meter

FROM dbo.Stores st
INNER JOIN dbo.Sales s
    ON st.StoreKey = s.StoreKey
INNER JOIN dbo.Products p
    ON s.ProductKey = p.ProductKey

WHERE st.StoreKey <> 0
  AND st.Square_Meters > 0

GROUP BY
    st.StoreKey,
    st.Square_Meters,
    st.Country,
    st.State

ORDER BY
    Profit_Per_Square_Meter DESC;


-- Finding:
-- Nevada generates the highest total profit among physical stores,
-- approximately $830,552.
--
-- Wyoming achieves the highest profit per square meter,
-- approximately $860.94/m², despite having only 840 m².
--
-- Insight:
-- The store generating the highest total profit is not necessarily
-- the most productive relative to its physical size.
--
-- Business recommendation:
-- Investigate Wyoming's product mix and operating practices
-- to understand its high sales-floor productivity.

--Next challenge: online versus physical stores

SELECT
    CASE
        WHEN s.StoreKey = 0 THEN 'Online'
        ELSE 'Physical'
    END AS Sales_Chennel,
    SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue
FROM dbo.Sales s
INNER JOIN dbo.Products p
    ON s.ProductKey = p.ProductKey

GROUP BY
    CASE
        WHEN s.StoreKey = 0 THEN 'Online'
        ELSE 'Physical'
    END
ORDER BY
    Revenue DESC;

--Does the online channel also dominate profitability,
--or does the physical channel have a stronger profit margin?

SELECT
    CASE
        WHEN s.StoreKey = 0 THEN 'Online'
        ELSE 'Physical'
    END AS Sales_Chennel,
    SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num) ) AS Total_profit,
       CAST(
    100.0 * SUM(
        s.Quantity *
        (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)
    )
    / NULLIF(
        SUM(s.Quantity * p.Unit_Price_USD_Num),
        0
    )
    AS DECIMAL(10,2)
) AS Profit_Margin 
FROM dbo.Sales s
INNER JOIN dbo.Products p
    ON s.ProductKey = p.ProductKey

GROUP BY
    CASE
        WHEN s.StoreKey = 0 THEN 'Online'
        ELSE 'Physical'
    END
ORDER BY
    Revenue DESC;

-- Finding:
-- Physical stores generate approximately $44.35M in revenue
-- and $25.99M in total profit.
-- The Online channel generates approximately $11.40M in revenue
-- and $6.67M in total profit.
--
-- Profit margins are very similar:
-- Physical: approximately 58.60%
-- Online: approximately 58.51%.
--
-- Insight:
-- Physical stores are the dominant sales and profit channel.
-- The difference in profitability is primarily driven by revenue
-- scale rather than a significant difference in profit margin.
--
-- Important distinction:
-- The Online store is the highest-performing individual location,
-- but physical stores collectively generate substantially more
-- revenue and profit than the Online channel.


-- =====================================================
-- 5.2 --CALCULATING STORE AGE  

-- =====================================================

SELECT
    st.StoreKey,
    st.Country,
    st.State,
    st.Open_Date,
    MAX(s.Order_Date) AS Latest_order,
    DATEDIFF(YEAR, st.Open_Date, MAX(s.Order_Date)) AS Store_Age_Years,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num) ) AS Total_profit,
  SUM(
    s.Quantity *
    (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)
    / st.Square_Meters
) AS Profit_Per_Square_Meter 
FROM dbo.Stores st
INNER JOIN dbo.Sales s
    ON st.StoreKey = s.StoreKey
INNER JOIN dbo.Products p
    ON s.Productkey = p.ProductKey
WHERE st.StoreKey <> 0
GROUP BY
    st.StoreKey,
    st.Country,
    st.State,
    st.Open_Date
ORDER BY
    Total_profit DESC;

--Next challenge: test the relationship

WITH Store_details AS (
   SELECT
        st.StoreKey,
        st.Country,
        st.Open_Date,
        MAX(s.Order_Date) AS Latest_order,
        DATEDIFF(YEAR, st.Open_Date, MAX(s.Order_Date)) AS Store_Age_Years,
        SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num) ) AS Total_profit,
        SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)/ st.Square_Meters ) AS Profit_Per_Square_Meter

  FROM dbo.Stores st
  INNER JOIN dbo.Sales s
    ON st.StoreKey = s.StoreKey
  INNER JOIN dbo.Products p
  ON s.Productkey = p.ProductKey
  WHERE st.StoreKey <> 0
  GROUP BY
    st.StoreKey,
        st.Country,
        st.Open_Date

)


     SELECT
        CASE
            WHEN Store_Age_Years <=5   THEN '0-5 years'
            WHEN Store_Age_Years <=10  THEN '6-10 years'
            WHEN Store_Age_Years <=15  THEN '11-15 years'
             ELSE '16 + years'
        END AS Age_grouping,
    COUNT(*) AS Number_of_Stores,
    AVG(Total_profit) AS Avg_total_profit,
    AVG(Profit_Per_Square_Meter) AS Avg_Profit_Per_Square_Meter
    FROM Store_details
    GROUP BY
        CASE
            WHEN Store_Age_Years <=5   THEN '0-5 years'
            WHEN Store_Age_Years <=10  THEN '6-10 years'
            WHEN Store_Age_Years <=15  THEN '11-15 years'
             ELSE '16 + years'
        END;
-- Finding:
-- Store age does not show a simple linear relationship with
-- store efficiency.
--
-- Stores aged 0-5 years have the lowest average profit and
-- profit per square meter.
-- The 6-10 year group shows substantially higher efficiency.
-- However, efficiency declines in the 11-15 year group.
--
-- The 16+ year group has the highest average profit per square
-- meter, but contains only 2 stores, so this result should be
-- interpreted cautiously.
--
-- Insight:
-- Store age alone does not appear sufficient to explain store
-- performance.
-- Wyoming is a notable outlier: despite being only 7 years old,
-- it generates approximately $861 profit per square meter,
-- substantially above the 6-10 year group average.
--
-- Recommendation:
-- Investigate Wyoming's product mix, customer profile, sales
-- volume and other operating characteristics to identify
-- practices that could potentially be replicated elsewhere.
        
--Business question
--What characteristics make Wyoming's 
--store performance unusually strong?


--Business question
--What characteristics make 
--Wyoming's store performance unusually strong?

SELECT
    st.StoreKey,
    st.State,
    SUM(s.Quantity) AS Units_Sold,
    SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num) ) AS Total_profit,
    COUNT(DISTINCT s.Order_Number) AS Total_Orders
FROM dbo.Stores st
INNER JOIN dbo.Sales s
      ON st.StoreKey = s.StoreKey
INNER JOIN dbo.Products p
      ON p.ProductKey = s.ProductKey 
WHERE st.StoreKey <> 0
GROUP BY
     st.StoreKey,
     st.State
ORDER BY Total_profit DESC;
        
--CALCULATE AVERAGE ORDER

SELECT
    st.StoreKey,
    st.State,
    SUM(s.Quantity) AS Units_Sold,
    SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num) ) AS Total_profit,
    COUNT(DISTINCT s.Order_Number) AS Total_Orders,
    SUM(s.Quantity * p.Unit_Price_USD_Num) / COUNT(DISTINCT s.Order_Number) Average_Order_Value,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num))
/
COUNT(DISTINCT s.Order_Number) AS Profit_Per_Order
FROM dbo.Stores st
INNER JOIN dbo.Sales s
      ON st.StoreKey = s.StoreKey
INNER JOIN dbo.Products p
      ON p.ProductKey = s.ProductKey 
WHERE st.State = 'Wyoming'
GROUP BY
     st.StoreKey,
     st.State
ORDER BY Average_Order_Value DESC;

--Why is Wyoming so efficient?

SELECT
 st.StoreKey,
 st.State,
 p.Category,
 SUM(s.Quantity) AS Units_Sold,
 SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue,
 SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num) ) AS Total_profit,
    CAST(
    100.0 * SUM(
        s.Quantity *
        (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)
    )
    / NULLIF(
        SUM(s.Quantity * p.Unit_Price_USD_Num),
        0
    )
    AS DECIMAL(10,2)
) AS Profit_Margin 
 FROM dbo.Stores st
INNER JOIN dbo.Sales s
      ON st.StoreKey = s.StoreKey
INNER JOIN dbo.Products p
      ON p.ProductKey = s.ProductKey 
WHERE st.State = 'Wyoming'
GROUP BY
    p.Category,
    st.StoreKey,
    st.State

--Do older stores actually generate more 
--profit than newer stores?

WITH Store_details AS(
    SELECT
         st.StoreKey,
         st.State,
         st.Open_Date,
         MAX(s.Order_Date) AS Latest_Order,
         DATEDIFF(YEAR, st.Open_Date, MAX(s.Order_Date)) AS Store_Age_Years,
    SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)) AS Total_Profit,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)/ st.Square_Meters) AS Profit_Per_Square_Meter
FROM dbo.Stores st
INNER JOIN dbo.Sales s
      ON st.StoreKey = s.StoreKey
INNER JOIN dbo.Products p
      ON p.ProductKey = s.ProductKey 
 WHERE st.StoreKey <> 0

    GROUP BY
        st.StoreKey,
        st.State,
        st.Open_Date,
        st.Square_Meters
)
  SELECT
    CASE
        WHEN Store_Age_Years <= 5 THEN '0-5 years'
        WHEN Store_Age_Years <= 10 THEN '6-10 years'
        WHEN Store_Age_Years <= 15 THEN '11-15 years'
        ELSE '16+ years'
    END AS Age_Group,

    COUNT(*) AS Number_of_Stores,
    AVG(Revenue) AS Avg_Revenue,
    AVG(Total_Profit) AS Avg_Total_Profit,
    AVG(Profit_Per_Square_Meter) AS Avg_Profit_Per_Square_Meter

FROM Store_details

GROUP BY
   CASE
        WHEN Store_Age_Years <= 5 THEN '0-5 years'
        WHEN Store_Age_Years <= 10 THEN '6-10 years'
        WHEN Store_Age_Years <= 15 THEN '11-15 years'
        ELSE '16+ years'
    END;

-- Finding:
-- Newer stores (0-5 years) have the lowest average revenue
-- and total profit among the age groups.
--
-- Established stores generally generate higher average revenue
-- and profit, but the relationship is not strictly linear.
--
-- Profit per square meter is highest for the 6-10 year and
-- 16+ year groups, suggesting that store age alone does not
-- fully explain store efficiency.
--
-- Important limitation:
-- The 16+ year group contains only 2 stores, so conclusions
-- about this group should be treated cautiously.


-- =====================================================
-- 6. CUSTOMER PURCHASING BEHAVIOR
-- =====================================================
--Customer Analysis — Question 1
--Business question
--Who are our highest-value customers?

--HIGHEST PROFIT PER ORDER WITH AT LEAST 3 ORDER


SELECT
    c.CustomerKey,
    c.Name,
    c.Country,
    SUM(s.Quantity) AS Units_Sold,
    SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)) AS Total_Profit,
    COUNT(DISTINCT s.Order_Number) AS Total_Orders,
    SUM (s.Quantity * p.Unit_Price_USD_Num) / COUNT(DISTINCT s.Order_Number) AS Avg_Order_Value,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)) / COUNT(DISTINCT s.Order_Number)
    AS Profit_Per_Order
FROM dbo.Customers c
INNER JOIN dbo.Sales s
    ON c.CustomerKey = s.CustomerKey
INNER JOIN dbo.Products p
    ON p.ProductKey = s.ProductKey
GROUP BY
    c.CustomerKey,
    c.Name,
    c.Country
HAVING COUNT(DISTINCT s.Order_Number) >= 3  
ORDER BY
    Profit_Per_Order DESC;


--WHO GENERATE THE MOST Total_Profit

SELECT
    c.CustomerKey,
    c.Name,
    c.Country,
    SUM(s.Quantity) AS Units_Sold,
    SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)) AS Total_Profit,
    COUNT(DISTINCT s.Order_Number) AS Total_Orders,
    SUM (s.Quantity * p.Unit_Price_USD_Num) / COUNT(DISTINCT s.Order_Number) AS Avg_Order_Value,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)) / COUNT(DISTINCT s.Order_Number)
    AS Profit_Per_Order
FROM dbo.Customers c
INNER JOIN dbo.Sales s
    ON c.CustomerKey = s.CustomerKey
INNER JOIN dbo.Products p
    ON p.ProductKey = s.ProductKey
GROUP BY
    c.Name,
    c.Country
HAVING COUNT(DISTINCT s.Order_Number) >= 3  
ORDER BY
    Total_Profit DESC;

--Which customers place the most orders?

SELECT
    c.CustomerKey,
    c.Name,
    c.Country,
    SUM(s.Quantity) AS Units_Sold,
    SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)) AS Total_Profit,
    COUNT(DISTINCT s.Order_Number) AS Total_Orders,
    SUM (s.Quantity * p.Unit_Price_USD_Num) / COUNT(DISTINCT s.Order_Number) AS Avg_Order_Value,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)) / COUNT(DISTINCT s.Order_Number)
    AS Profit_Per_Order
FROM dbo.Customers c
INNER JOIN dbo.Sales s
    ON c.CustomerKey = s.CustomerKey
INNER JOIN dbo.Products p
    ON p.ProductKey = s.ProductKey
GROUP BY
    c.CustomerKey,
    c.Name,
    c.Country 
ORDER BY
    Total_Orders DESC;

    
--Which customers generate the most profit per order?


SELECT
    c.CustomerKey,
    c.Name,
    c.Country,
    SUM(s.Quantity) AS Units_Sold,
    SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)) AS Total_Profit,
    COUNT(DISTINCT s.Order_Number) AS Total_Orders,
    SUM (s.Quantity * p.Unit_Price_USD_Num) / COUNT(DISTINCT s.Order_Number) AS Avg_Order_Value,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)) / COUNT(DISTINCT s.Order_Number)
    AS Profit_Per_Order
FROM dbo.Customers c
INNER JOIN dbo.Sales s
    ON c.CustomerKey = s.CustomerKey
INNER JOIN dbo.Products p
    ON p.ProductKey = s.ProductKey
GROUP BY
    c.CustomerKey,
    c.Name,
    c.Country
HAVING COUNT(DISTINCT s.Order_Number) >= 3  
ORDER BY
    Total_Profit DESC;

    --Which customers place the most orders?

SELECT
    c.CustomerKey,
    c.Name,
    c.Country,
    SUM(s.Quantity) AS Units_Sold,
    SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)) AS Total_Profit,
    COUNT(DISTINCT s.Order_Number) AS Total_Orders,
    SUM (s.Quantity * p.Unit_Price_USD_Num) / COUNT(DISTINCT s.Order_Number) AS Avg_Order_Value,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)) / COUNT(DISTINCT s.Order_Number)
    AS Profit_Per_Order
FROM dbo.Customers c
INNER JOIN dbo.Sales s
    ON c.CustomerKey = s.CustomerKey
INNER JOIN dbo.Products p
    ON p.ProductKey = s.ProductKey
GROUP BY
    c.CustomerKey,
    c.Name,
    c.Country 
HAVING COUNT(DISTINCT s.Order_Number) >= 3
ORDER BY
    Profit_Per_Order DESC;

 -- Finding:
-- Customers with fewer orders can still generate substantial value.
-- Karen Jones generated approximately $28.8K total profit from only
-- 3 orders, with approximately $9.6K profit per order.

-- Insight:
-- Customer value is influenced not only by purchase frequency,
-- but also by the profitability of each order.

-- Recommendation:
-- The business should identify high-profit-per-order customers
-- and investigate what products or purchasing patterns drive
-- their high profitability.

  

  WITH Customer_Summary AS(
    SELECT
        c.CustomerKey AS Customer_key,
        c.Name AS Customer_Name,
        c.Country AS Customer_Country,
        SUM(s.Quantity) AS Units_Sold,
        SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue,
        SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)) AS Total_Profit,
        COUNT(DISTINCT s.Order_Number) AS Total_Orders 
    FROM dbo.Customers c
    INNER JOIN dbo.Sales s
         ON c.CustomerKey = s.CustomerKey
    INNER JOIN dbo.Products p
         ON p.ProductKey = s.ProductKey
    GROUP BY
     c.CustomerKey,
     c.Name,
     c.Country 
)

        SELECT
            Customer_key,
            Customer_Name,
            Customer_Country,
            Units_Sold,
            Revenue,
            Total_Profit,
            Total_Orders,
            Revenue / Total_Orders AS Avg_Order_Value,
            Total_Profit / Total_Orders  AS Profit_Per_Order
        FROM Customer_Summary
        WHERE Total_Orders >=3
        ORDER BY
            Profit_Per_Order DESC;


--How many customers fall into different levels of total profit?
            
 WITH Customer_Summary AS (
    SELECT
        c.CustomerKey AS Customer_key,
        c.Name AS Customer_Name,
        c.Country AS Customer_Country,
        SUM(
            s.Quantity *
            (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)
        ) AS Total_Profit
    FROM dbo.Customers c
    INNER JOIN dbo.Sales s
        ON c.CustomerKey = s.CustomerKey
    INNER JOIN dbo.Products p
        ON s.ProductKey = p.ProductKey
    GROUP BY
        c.CustomerKey,
        c.Name,
        c.Country
),
Customer_Quartile AS (
    SELECT
        Customer_key,
        Total_Profit,
        NTILE(4) OVER (
            ORDER BY Total_Profit DESC, Customer_key
        ) AS Profit_Quartile
    FROM Customer_Summary
)
SELECT
    Profit_Quartile,
    COUNT(*) AS Number_of_Customers,
    SUM(Total_Profit) AS Total_Profit,
    CAST(
        100.0 * SUM(Total_Profit)
        / SUM(SUM(Total_Profit)) OVER ()
        AS DECIMAL(10, 2)
    ) AS Profit_Share_Percent
FROM Customer_Quartile
GROUP BY Profit_Quartile
ORDER BY Profit_Quartile;

/*
  **Finding**
- Customers with sales were divided into four nearly equal groups based on total estimated profit.
- Each quartile contains approximately 25% of customers.
- The top 25% of customers by profitability generate approximately 64.10% of total estimated profit, while the bottom 25% generate only 2.51%.

**Insight**

Estimated profit is highly concentrated among a relatively small group of high-value customers.

**Recommendation**

Prioritize retention and personalized offers for high-profit customers. Investigate their purchasing behavior to identify products, categories, and customer characteristics associated with higher profitability.

**Key takeaway:** The top 25% of customers by profitability generate approximately 64.1% of total estimated profit.

*/

WITH Customer_Summary AS(
    SELECT
        c.CustomerKey AS Customer_key,
        c.Name AS Customer_Name,
        c.Country AS Customer_Country,
        SUM(s.Quantity) AS Units_Sold,
        SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue,
        SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)) AS Total_Profit,
        COUNT(DISTINCT s.Order_Number) AS Total_Orders 
    FROM dbo.Customers c
    INNER JOIN dbo.Sales s
         ON c.CustomerKey = s.CustomerKey
    INNER JOIN dbo.Products p
         ON p.ProductKey = s.ProductKey
    GROUP BY
     c.CustomerKey,
     c.Name,
     c.Country 
),
Customer_Quartile AS(
    SELECT
         NTILE(4) OVER (
         ORDER BY Total_Profit DESC,
                    Customer_key

         
) AS Profit_Quartile,
            Customer_Country,
            Revenue,
            Total_Profit,
            Total_Orders
  FROM Customer_Summary

)
    SELECT
        Customer_Country,
        Profit_Quartile,
        COUNT(*) AS Number_of_Customers,
        SUM(Revenue) AS Total_Revenue,
        SUM(Total_Profit) AS Total_Profit,
        100.0 * SUM(Total_Profit)
    / SUM(SUM(Total_Profit)) OVER () AS Profit_Share_Percent
    FROM Customer_Quartile
    WHERE Profit_Quartile = 1
    GROUP BY
     Profit_Quartile,
     Customer_Country
    ORDER BY
        Number_of_Customers DESC;
   
--Business Question
--Which countries contribute the most profit among the top 25% 
--of customers by profitability?

--**Finding**
--The United States contributes approximately $11.86 million, or 56.66%, of total profit
--generated by the top customer quartile. The United Kingdom contributes 12.55%, followed by Germany at 9.79%.

--**Business Insight**
--The company's most profitable customer segment is concentrated in the United States,
--with the UK and Germany representing other important markets.

--**Recommendation**
--Prioritize retention strategies for high-profit customers in the United States, UK, and Germany. 
--Investigate whether customer purchasing patterns, product preferences, or order frequency explain the
--differences between countries. Continue nurturing profitable customers in smaller markets rather than 
--overlooking them because of lower overall contribution.  


        


        WITH Customer_Summary AS(
    SELECT
        c.CustomerKey AS Customer_key,
        c.Name AS Customer_Name,
        c.Country AS Customer_Country,
        SUM(s.Quantity) AS Units_Sold,
        SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue,
        SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)) AS Total_Profit,
        COUNT(DISTINCT s.Order_Number) AS Total_Orders 
    FROM dbo.Customers c
    INNER JOIN dbo.Sales s
         ON c.CustomerKey = s.CustomerKey
    INNER JOIN dbo.Products p
         ON p.ProductKey = s.ProductKey
    GROUP BY
     c.CustomerKey,
     c.Name,
     c.Country 
),
Customer_Quartile AS(
    SELECT
         NTILE(4) OVER (
         ORDER BY Total_Profit DESC
) AS Profit_Quartile,
            Customer_Country,
            Revenue,
            Total_Profit,
            Total_Orders,
            Units_Sold
  FROM Customer_Summary

)
    SELECT
      
        Profit_Quartile,
        COUNT(*) AS Number_of_Customers,
        AVG(Revenue) AS Avg_Revenue_per_customer,
        AVG(Total_Profit) AS Avg_profit_per_customer,
       AVG(1.0 * Total_Orders) AS Avg_Number_of_order_per_customer
    FROM Customer_Quartile
    GROUP BY
         Profit_Quartile
        
    ORDER BY
         Profit_Quartile;
  

 -- **Business Question:** How do customer purchasing behaviors differ across profit quartiles?

--**Finding:** 
--The highest-profit customer quartile averages approximately $7,044.36 in profit per customer and 3.37 orders per customer. 
--The lowest-profit quartile averages approximately $275.18 in profit and 1.29 orders per customer.

--**Business Insight:** 
--Higher-profit customers tend to generate more revenue and purchase more frequently.
--Customer order frequency may be one factor associated with profitability.

--**Recommendation:**
--Prioritize retention initiatives for high-profit customers. 
--Investigate ways to encourage repeat purchases among lower-profit customers, 
--while considering the cost of incentives and the profit they generate.
        
        
--Do high-profit customers prefer different product categories 
--from lower-profit customers?


WITH Customer_Summary AS(
    SELECT
        c.Name AS Customer_Name,
        c.Country AS Customer_Country,
        p.Category AS Product_Category,
        SUM(s.Quantity) AS Units_Sold,
        SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue,
        SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)) AS Total_Profit,
        COUNT(DISTINCT s.Order_Number) AS Total_Orders 
    FROM dbo.Customers c
    INNER JOIN dbo.Sales s
         ON c.CustomerKey = s.CustomerKey
    INNER JOIN dbo.Products p
         ON p.ProductKey = s.ProductKey
    GROUP BY
     c.Name,
     c.Country,
     p.Category
),
Customer_Quartile AS(
    SELECT
         NTILE(4) OVER (
         ORDER BY Total_Profit DESC
) AS Profit_Quartile,
            Customer_Country,
            Product_Category,
            Revenue,
            Total_Profit,
            Total_Orders
  FROM Customer_Summary

)
    SELECT
        Customer_Country,
        Product_Category,
        Profit_Quartile,
        COUNT(*) AS Number_of_Customers,
        SUM(Revenue) AS Total_Revenue,
        SUM(Total_Profit) AS Total_Profit,
        100.0 * SUM(Total_Profit)
    / SUM(SUM(Total_Profit)) OVER () AS Profit_Share_Percent
    FROM Customer_Quartile
    GROUP BY
     Profit_Quartile,
     Customer_Country,
     Product_Category
   ORDER BY
    Profit_Quartile ASC,
    Total_Profit DESC;
   
   /*
Business Question:
Do high-profit customers prefer different product categories
from lower-profit customers?

Findings:
1. Computers generate the most profit among Quartile 1 customers.
2. Games and Toys lead among Quartile 4 customers in this analysis.
3. Audio may present opportunities in smaller markets.
Business Insight:
Product-category performance may vary by customer profitability
and country.

Recommendation:
Prioritize profitable computer products for high-value customers.
Investigate whether targeted promotions can increase purchases
among lower-profit customers without sacrificing profit margins.

Further Investigation:
Compare profit margins and category-level profit shares across
customer quartiles and countries before finalizing recommendations.
*/
 
 
 /*
Business question
How does the number of orders placed by a customer relate to their total profit?
*/

WITH Customer_Summary AS(
    SELECT
       c.CustomerKey AS customer_Key,
        c.Name AS Customer_Name, 
        SUM(s.Quantity) AS Units_Sold,
        SUM(s.Quantity * p.Unit_Price_USD_Num) AS Revenue,
        SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)) AS Total_Profit,
        COUNT(DISTINCT s.Order_Number) AS Total_Orders 
 
    FROM dbo.Customers c
    INNER JOIN dbo.Sales s
         ON c.CustomerKey = s.CustomerKey
    INNER JOIN dbo.Products p
         ON p.ProductKey = s.ProductKey
    GROUP BY
     c.Name,
     c.CustomerKey
)
    SELECT
CASE
    WHEN Total_Orders = 1 THEN '1 Order'
    WHEN Total_Orders BETWEEN 2 AND 3 THEN '2-3 Orders'
    WHEN Total_Orders BETWEEN 4 AND 6 THEN '4-6 Orders'
ELSE
 '7+ Orders'
    
END AS Group_order,
AVG(Revenue) AS Average_Revenue,
AVG(Total_Profit) AS Average_total_profit,
SUM(Total_Profit) AS Total_profit_generated,
COUNT(*) AS Number_of_Customers

FROM Customer_Summary
GROUP BY
CASE
    WHEN Total_Orders = 1 THEN '1 Order'
    WHEN Total_Orders BETWEEN 2 AND 3 THEN '2-3 Orders'
    WHEN Total_Orders BETWEEN 4 AND 6 THEN '4-6 Orders'
ELSE
 '7+ Orders'   
END
ORDER BY
Group_order;

/*
BUSINESS QUESTION:
How does customer order frequency relate to profitability?

KEY FINDINGS:
1. Customers placing 7+ orders generate the highest average
   profit per customer.

2. Customers placing 2-3 orders generate the highest total
   profit across all four groups.

3. The 7+ orders group contains only 156 customers, making
   it a small but valuable customer segment.

BUSINESS RECOMMENDATIONS:
1. Develop retention strategies for high-profit repeat customers.
2. Encourage customers who placed 2-3 orders to purchase again.
3. Investigate the purchasing patterns of customers who place
   7+ orders to identify opportunities to retain similar customers.

LIMITATION:
The analysis shows an association between order frequency
and profit; it does not establish that increasing order
frequency alone causes higher profitability.
*/


SELECT
    c.CustomerKey AS customer_Key,
    c.Name AS Customer_name,
    c.Country AS Customer_country,
    MAX(s.Order_Date) AS Recent_order_date,
    COUNT(DISTINCT s.Order_Number) AS Number_of_order,
    DATEDIFF(
    day,
    MAX(s.Order_Date),
    (SELECT MAX(Order_Date) FROM dbo.Sales)
) AS Days_Since_Last_Order
FROM dbo.Customers c
INNER JOIN dbo.Sales s
    ON c.CustomerKey = s.CustomerKey
GROUP BY
    c.CustomerKey,
    c.Name,
    c.Country
ORDER BY Recent_order_date DESC;


-- =====================================================
-- 7. CUSTOMER INACTIVITY AND RE-ENGAGEMENT
-- =====================================================


/*
Next step: Identify potentially inactive customers
*/
    
WITH Customer_details AS(     
SELECT
    c.CustomerKey AS customer_Key,
    c.Name AS Customer_name,
    c.Country AS Customer_country,
    MAX(s.Order_Date) AS Recent_order_date,
    COUNT(DISTINCT s.Order_Number) AS Number_of_order,
    DATEDIFF(
    day,
    MAX(s.Order_Date),
    (SELECT MAX(Order_Date) FROM dbo.Sales)
) AS Days_Since_Last_Order

FROM dbo.Customers c
INNER JOIN dbo.Sales s
    ON c.CustomerKey = s.CustomerKey
GROUP BY
    c.CustomerKey,
    c.Name,
    c.Country
)

SELECT
      customer_Key,
      Customer_name,
      Customer_country,
      Recent_order_date,
      Number_of_order,
      Days_Since_Last_Order,
      CASE
    WHEN Days_Since_Last_Order <= 30 THEN 'Recently Active'
    WHEN Days_Since_Last_Order <= 90 THEN 'At Risk'
    ELSE 'Potentially Inactive'
END AS Customer_Status
FROM Customer_details;


--HOW many customers fall into each status?

WITH Customer_details AS(     
SELECT
    c.CustomerKey AS customer_Key,
    c.Name AS Customer_name,
    c.Country AS Customer_country,
    MAX(s.Order_Date) AS Recent_order_date,
    COUNT(DISTINCT s.Order_Number) AS Number_of_order,
    DATEDIFF(
    day,
    MAX(s.Order_Date),
    (SELECT MAX(Order_Date) FROM dbo.Sales)
) AS Days_Since_Last_Order

FROM dbo.Customers c
INNER JOIN dbo.Sales s
    ON c.CustomerKey = s.CustomerKey
GROUP BY
    c.CustomerKey,
    c.Name,
    c.Country
),
Customers_Status AS(
SELECT
      customer_Key,
      Customer_name,
      Customer_country,
      Recent_order_date,
      Number_of_order,
      Days_Since_Last_Order,
      CASE
    WHEN Days_Since_Last_Order <= 30 THEN 'Recently Active'
    WHEN Days_Since_Last_Order <= 90 THEN 'At Risk'
    ELSE 'Potentially Inactive'
END AS Customer_Status
FROM Customer_details
)
SELECT
Customer_Status,
COUNT(*) Number_of_customers
FROM Customers_Status
GROUP BY Customer_Status;

/*
BUSINESS QUESTION:
How many customers fall into each activity status?

FINDING:
318 customers were recently active, 502 were at risk,
and 11,067 were potentially inactive based on the
30-day and 90-day thresholds.

BUSINESS INSIGHT:
Most customers had not purchased recently relative
to the final date in the dataset.

RECOMMENDATION:
Investigate historical customer retention and consider
targeted re-engagement campaigns for valuable former
customers.

LIMITATION:
The dataset ends in February 2021. These statuses
describe historical activity and do not establish
customers' current activity.
*/

  /*
  which customers are worth winning back

  Business question: Among the potentially inactive customers, 
  which ones generated the most profit before they stopped purchasing?

  */
WITH Customer_details AS(     
SELECT
    c.CustomerKey AS customer_Key,
    c.Name AS Customer_name,
    c.Country AS Customer_country,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)) AS Total_Profit,
    MAX(s.Order_Date) AS Recent_order_date,
    COUNT(DISTINCT s.Order_Number) AS Number_of_order,
    DATEDIFF(
    day,
    MAX(s.Order_Date),
    (SELECT MAX(Order_Date) FROM dbo.Sales)
) AS Days_Since_Last_Order

FROM dbo.Customers c
INNER JOIN dbo.Sales s
    ON c.CustomerKey = s.CustomerKey
INNER JOIN dbo.Products p
    ON p.ProductKey = s.ProductKey
GROUP BY
    c.CustomerKey,
    c.Name,
    c.Country
),
Customers_Status AS(
SELECT
      customer_Key,
      Customer_name,
      Customer_country,
      Recent_order_date,
      Number_of_order,
      Days_Since_Last_Order,
      Total_Profit,
      CASE
    WHEN Days_Since_Last_Order <= 30 THEN 'Recently Active'
    WHEN Days_Since_Last_Order <= 90 THEN 'At Risk'
    ELSE 'Potentially Inactive'
END AS Customer_Status
FROM Customer_details
)
SELECT
      customer_Key,
      Customer_name,
      Customer_country,
      Recent_order_date,
      Number_of_order,
      Days_Since_Last_Order,
      Customer_Status,
      Total_Profit,
      CASE
        WHEN Total_Profit >= 20000 AND Number_of_order >=3 THEN 'High Priority'
        WHEN Total_Profit >= 10000 THEN 'Medium Priority'
      ELSE 'Low Priority'
      END AS Customer_Priority
          
FROM Customers_Status
WHERE Customer_Status = 'Potentially Inactive'
GROUP BY
       customer_Key,
       Customer_name,
       Customer_country,
       Customer_Status,
       Recent_order_date,
       Number_of_order,
       Days_Since_Last_Order,
       Total_Profit  
ORDER BY Total_Profit DESC;



--How many customers fall into each priority group

WITH Customer_details AS(     
SELECT
 c.CustomerKey AS customer_Key,
    c.Name AS Customer_name,
    c.Country AS Customer_country,
    SUM(s.Quantity * (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)) AS Total_Profit,
    MAX(s.Order_Date) AS Recent_order_date,
    COUNT(DISTINCT s.Order_Number) AS Number_of_order,
    DATEDIFF(
    day,
    MAX(s.Order_Date),
    (SELECT MAX(Order_Date) FROM dbo.Sales)
) AS Days_Since_Last_Order

FROM dbo.Customers c
INNER JOIN dbo.Sales s
    ON c.CustomerKey = s.CustomerKey
INNER JOIN dbo.Products p
    ON p.ProductKey = s.ProductKey
GROUP BY
    c.CustomerKey,
    c.Name,
    c.Country
),
Customers_Status AS(
SELECT
      customer_Key,
      Customer_name,
      Customer_country,
      Recent_order_date,
      Number_of_order,
      Days_Since_Last_Order,
      Total_Profit,
      CASE
    WHEN Days_Since_Last_Order <= 30 THEN 'Recently Active'
    WHEN Days_Since_Last_Order <= 90 THEN 'At Risk'
    ELSE 'Potentially Inactive'
END AS Customer_Status
FROM Customer_details
),
Customers_priorty_table AS(
SELECT
      customer_Key,
      Customer_name,
      Customer_country,
      Recent_order_date,
      Number_of_order,
      Days_Since_Last_Order,
      Customer_Status,
      Total_Profit,
      CASE
        WHEN Total_Profit >= 20000 AND Number_of_order >=3 THEN 'High Priority'
        WHEN Total_Profit >= 10000 THEN 'Medium Priority'
      ELSE 'Low Priority'
      END AS Customer_Priority
          
FROM Customers_Status
WHERE Customer_Status = 'Potentially Inactive'
GROUP BY
       customer_Key,
       Customer_name,
       Customer_country,
       Customer_Status,
       Recent_order_date,
       Number_of_order,
       Days_Since_Last_Order,
       Total_Profit  

)

SELECT
    Customer_Priority,
    COUNT(*) AS Number_of_customers,
    SUM(Total_Profit) AS Historical_Profit
FROM Customers_priorty_table
GROUP BY 
      Customer_Priority
ORDER BY Historical_Profit DESC;


/*
**Business Question:** How should the company prioritize potentially inactive customers for a win-back campaign?

**Finding:** The analysis identified 23 high-priority customers with approximately $541K in historical profit,
376 medium-priority customers with approximately $5.00M, and 10,688 low-priority customers with approximately $23.90M.

**Business Insight:** A small group of customers can be targeted with personalized outreach, 
while larger groups may require more scalable, lower-cost retention campaigns.

**Recommendation:** Begin with the high-priority group, test a targeted reactivation campaign, and measure 
the response rate and profit from returning customers. Then evaluate whether the medium-priority group warrants a broader campaign.

**Limitation:** Historical profit is not guaranteed future profit. The priority thresholds are project 
assumptions and should be validated against campaign costs and actual customer responses.
*/



/*
Business Question:
Among potentially inactive customers, which product categories
generate the most historical profit, and which customer priority
groups should the business focus on winning back?

Important:
Customer status and priority are calculated using each customer's
overall purchase history. Category profit is calculated separately
in the final query.
*/

WITH Customer_details AS (
    SELECT
        c.CustomerKey,
        c.Name AS Customer_name,
        c.Country AS Customer_country,

        SUM(
            s.Quantity *
            (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)
        ) AS Total_Profit,

        MAX(s.Order_Date) AS Recent_order_date,

        COUNT(DISTINCT s.Order_Number) AS Number_of_order,

        DATEDIFF(
            DAY,
            MAX(s.Order_Date),
            (SELECT MAX(Order_Date) FROM dbo.Sales)
        ) AS Days_Since_Last_Order

    FROM dbo.Customers c

    INNER JOIN dbo.Sales s
        ON c.CustomerKey = s.CustomerKey

    INNER JOIN dbo.Products p
        ON s.ProductKey = p.ProductKey

    GROUP BY
        c.CustomerKey,
        c.Name,
        c.Country
),

Customers_Status AS (
    SELECT
        CustomerKey,
        Customer_name,
        Customer_country,
        Recent_order_date,
        Number_of_order,
        Days_Since_Last_Order,
        Total_Profit,

        CASE
            WHEN Days_Since_Last_Order <= 30
                THEN 'Recently Active'
            WHEN Days_Since_Last_Order <= 90
                THEN 'At Risk'
            ELSE 'Potentially Inactive'
        END AS Customer_Status

    FROM Customer_details
),

Customers_priorty_table AS (
    SELECT
        CustomerKey,
        Customer_name,
        Customer_country,
        Recent_order_date,
        Number_of_order,
        Days_Since_Last_Order,
        Customer_Status,
        Total_Profit,

        CASE
            WHEN Total_Profit >= 20000
                 AND Number_of_order >= 3
                THEN 'High Priority'

            WHEN Total_Profit >= 10000
                THEN 'Medium Priority'

            ELSE 'Low Priority'
        END AS Customer_Priority

    FROM Customers_Status

    WHERE Customer_Status = 'Potentially Inactive'
)

SELECT
    cp.Customer_Priority,
    p.Category AS Product_Category,

    COUNT(DISTINCT cp.CustomerKey) AS Number_of_Customers,

    SUM(
        s.Quantity *
        (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)
    ) AS Historical_Profit

FROM Customers_priorty_table cp

INNER JOIN dbo.Sales s
    ON cp.CustomerKey = s.CustomerKey

INNER JOIN dbo.Products p
    ON s.ProductKey = p.ProductKey

GROUP BY
    cp.Customer_Priority,
    p.Category

ORDER BY
    CASE cp.Customer_Priority
        WHEN 'High Priority' THEN 1
        WHEN 'Medium Priority' THEN 2
        WHEN 'Low Priority' THEN 3
    END,
    Historical_Profit DESC;


    /*
Business Question:
Which product categories generated the most historical profit
among potentially inactive customers in each priority group?

Findings:
1. High-priority customers generated the most historical profit
   from Home Appliances ($211,172.79), followed by TV and Video
   ($148,001.28) and Computers ($113,843.30).

2. Among medium-priority customers, Computers generated
   approximately $1.66M, followed by Home Appliances at $1.52M.

3. Among low-priority customers, Computers generated
   approximately $8.24M, followed by Home Appliances at $4.10M.

Business Insight:
Computers and Home Appliances are important profit-generating
categories across the inactive-customer priority groups.
Home Appliances and TV and Video also stand out among
high-priority customers.

Recommendation:
Test personalized win-back campaigns for high-priority customers.
For medium-priority customers, investigate targeted campaigns
for Computers and Home Appliances. Evaluate campaign costs,
response rates and incremental profit before scaling.

Limitation:
Historical profit does not establish future customer value.
Priority thresholds are assumptions and should be validated.

Customer counts across categories are not additive. 
A customer who bought from several categories is counted once in each of those categories.
*/

WITH Customer_details AS (
    SELECT
        c.CustomerKey,
        c.Name AS Customer_name,
        c.Country AS Customer_country,

        SUM(
            s.Quantity *
            (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)
        ) AS Total_Profit,

        MAX(s.Order_Date) AS Recent_order_date,

        COUNT(DISTINCT s.Order_Number) AS Number_of_order,

        DATEDIFF(
            DAY,
            MAX(s.Order_Date),
            (SELECT MAX(Order_Date) FROM dbo.Sales)
        ) AS Days_Since_Last_Order

    FROM dbo.Customers c

    INNER JOIN dbo.Sales s
        ON c.CustomerKey = s.CustomerKey

    INNER JOIN dbo.Products p
        ON s.ProductKey = p.ProductKey

    GROUP BY
        c.CustomerKey,
        c.Name,
        c.Country
),

Customers_Status AS (
    SELECT
        CustomerKey,
        Customer_name,
        Customer_country,
        Recent_order_date,
        Number_of_order,
        Days_Since_Last_Order,
        Total_Profit,

        CASE
            WHEN Days_Since_Last_Order <= 30
                THEN 'Recently Active'
            WHEN Days_Since_Last_Order <= 90
                THEN 'At Risk'
            ELSE 'Potentially Inactive'
        END AS Customer_Status

    FROM Customer_details
),

Customers_priorty_table AS (
    SELECT
        CustomerKey,
        Customer_name,
        Customer_country,
        Recent_order_date,
        Number_of_order,
        Days_Since_Last_Order,
        Customer_Status,
        Total_Profit,

        CASE
            WHEN Total_Profit >= 20000
                 AND Number_of_order >= 3
                THEN 'High Priority'

            WHEN Total_Profit >= 10000
                THEN 'Medium Priority'

            ELSE 'Low Priority'
        END AS Customer_Priority

    FROM Customers_Status

    WHERE Customer_Status = 'Potentially Inactive'
)

SELECT
    Customer_Priority,
    COUNT(DISTINCT CustomerKey) AS Number_of_Customers,
    SUM(Total_Profit) AS Historical_Profit,
    AVG(Total_Profit) AS Avg_Profit_per_Customer
FROM Customers_priorty_table
GROUP BY Customer_Priority
ORDER BY
    CASE Customer_Priority
        WHEN 'High Priority' THEN 1
        WHEN 'Medium Priority' THEN 2
        WHEN 'Low Priority' THEN 3
    END;
  /*
**Business Question:** Which potentially inactive customer priority group has the greatest historical profit?

**Findings:**
- High-priority customers: 23 customers, $541,119.77 historical profit, and $23,526.95 average profit per customer.
- Medium-priority customers: 376 customers, $4,997,610.31 historical profit, and $13,291.52 average profit per customer.
- Low-priority customers: 10,668 customers, $23,890,143.77 historical profit, and $2,239.42 average profit per customer.

**Business Insight:** High-priority customers have the greatest average historical profit per customer,
while low-priority customers contribute the largest total historical profit because the group is much larger.

**Recommendation:** Prioritize personalized win-back campaigns for high-priority customers, 
test targeted offers for medium-priority customers, and consider low-cost reactivation campaigns for the much larger low-priority group.

**Limitation:** Historical profit does not guarantee future profit. Evaluate campaign response rates, 
costs, and incremental profit before scaling the campaigns.

*/

--Business question: 
--Which countries contain the most high-priority inactive customers, and how much historical profit didthose customers generate?

WITH Customer_details AS (
    SELECT
        c.CustomerKey,
        c.Name AS Customer_name,
        c.Country AS Customer_country,

        SUM(
            s.Quantity *
            (p.Unit_Price_USD_Num - p.Unit_Cost_USD_Num)
        ) AS Total_Profit,

        MAX(s.Order_Date) AS Recent_order_date,

        COUNT(DISTINCT s.Order_Number) AS Number_of_order,

        DATEDIFF(
            DAY,
            MAX(s.Order_Date),
            (SELECT MAX(Order_Date) FROM dbo.Sales)
        ) AS Days_Since_Last_Order

    FROM dbo.Customers c

    INNER JOIN dbo.Sales s
        ON c.CustomerKey = s.CustomerKey

    INNER JOIN dbo.Products p
        ON s.ProductKey = p.ProductKey

    GROUP BY
        c.CustomerKey,
        c.Name,
        c.Country
),

Customers_Status AS (
    SELECT
        CustomerKey,
        Customer_name,
        Customer_country,
        Recent_order_date,
        Number_of_order,
        Days_Since_Last_Order,
        Total_Profit,

        CASE
            WHEN Days_Since_Last_Order <= 30
                THEN 'Recently Active'
            WHEN Days_Since_Last_Order <= 90
                THEN 'At Risk'
            ELSE 'Potentially Inactive'
        END AS Customer_Status

    FROM Customer_details
),

Customers_priorty_table AS (
    SELECT
        CustomerKey,
        Customer_name,
        Customer_country,
        Recent_order_date,
        Number_of_order,
        Days_Since_Last_Order,
        Customer_Status,
        Total_Profit,

        CASE
            WHEN Total_Profit >= 20000
                 AND Number_of_order >= 3
                THEN 'High Priority'

            WHEN Total_Profit >= 10000
                THEN 'Medium Priority'

            ELSE 'Low Priority'
        END AS Customer_Priority

    FROM Customers_Status

    WHERE Customer_Status = 'Potentially Inactive'
)

SELECT
    Customer_country,
    Customer_Priority,
    COUNT(DISTINCT CustomerKey) AS Number_of_Customers,
    SUM(Total_Profit) AS Historical_Profit,
    AVG(Total_Profit) AS Avg_Profit_per_Customer
FROM Customers_priorty_table
WHERE Customer_Priority = 'High Priority'
GROUP BY Customer_Priority,  Customer_country
ORDER BY
   Historical_Profit DESC;
/*
      **Business Question:**
      Which countries contain the most high-priority inactive customers, 
      and how much historical profit did they generate?

**Findings:**
- The United States had 14 high-priority customers, generating $340,482.20 in historical-profit segment to test.
- Germany had 3 customers generating $69,673.58.
- The United Kingdom had 3 customers generating $62,252.55.
- Canada, the Netherlands, and Italy each had one customer in this group.
--Adds up to 23 high-priority customers.

**Business Insight:**
The United States represents the largest immediate opportunity for high-priority customer win-back efforts, 
contributing approximately 63% of the group's historical profit.

**Recommendation:**
Begin by testing personalized win-back campaigns in the United States, 
then consider Germany and the United Kingdom. Evaluate response rates, campaign costs, and incremental profit before expanding.

**Limitation:** 
Historical profit does not guarantee future profit,
and the small customer counts in some countries limit market-level conclusions.
 */

 
 SELECT COUNT(*) AS CustomersWithoutSales
FROM dbo.Customers c
LEFT JOIN dbo.Sales s
    ON c.CustomerKey = s.CustomerKey
WHERE s.CustomerKey IS NULL;

-- Scope: Activity status and win-back priorities include customers
-- with at least one recorded sale. The 3,379 customers with no
-- recorded sales are excluded and should be considered separately.