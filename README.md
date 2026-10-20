# global-electronics-retail-analysis
SQL and Power BI analysis of sales, products, customers, delivery times, and win-back priorities
Global Electronics Retail Analysis

A SQL Server and Power BI portfolio project analyzing sales performance, product categories, customer locations, delivery times, and inactive-customer win-back priorities.

Business Questions
Which product categories generate the most revenue, and where are customers located?
How do revenue and order volume change over time?
What is the average delivery time, and how does it change by year?
How does average order value compare between online and in-store orders?
Which potentially inactive customers should be prioritized for a win-back campaign?


Key Findings
Revenue peaked in 2019 and declined in 2020. 2021 contains January and February only, so it is not directly comparable with full years.
Computers had the highest revenue among the product categories shown. The United States had the largest customer count by country.
Average delivery time was approximately 4.52 days.
Average order value was approximately $2,138 in-store and $2,044 online. In-store orders averaged about $94 (4.6%) more.
The win-back analysis identified 23 high-priority, 376 medium-priority, and 10,668 low-priority potentially inactive customers. Their combined historical profit was approximately $29.43 million.


Method
Revenue: quantity multiplied by unit price in USD.
Average order value: revenue divided by distinct order count.
Online channel: identified by StoreKey 0, whose store record is labeled “Online”; other store keys represent in-store sales.

Potentially inactive: more than 90 days since the customer’s last order, measured against the latest order date in the dataset.

Customer priority uses project-defined historical-profit and order-count thresholds.

Tools and Files

SQL Server — data checks and analysis.

Power BI Desktop — data model, measures, and report visuals.

.sql — analysis queries.

.pbix — interactive Power BI report.

Limitations

2021 data covers January–February only.

Priority thresholds are project assumptions and should be validated against campaign costs and actual customer responses.

Historical profit does not guarantee future profit.

The dataset does not include campaign results, so win-back effectiveness has not been measured.
