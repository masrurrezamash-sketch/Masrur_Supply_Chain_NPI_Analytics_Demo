/*
====================================================================================
PROJECT: ENTERPRISE SUPPLY CHAIN ANALYTICS & RISK MANAGEMENT
DATASET: Masrur Supply Chain Analytics (Programs A-E)
DIALECT: Written in ANSI-style SQL and tested in PostgreSQL / BigQuery / SQL Server.

DESCRIPTION: 
This comprehensive script utilizes advanced SQL techniques (CTEs, Window Functions, 
Conditional Aggregations, and Multi-Table Joins) to extract actionable intelligence 
across inventory coverage, supplier risk, PO fulfillment, and demand variance.
====================================================================================
*/

-- =================================================================================
-- 1. SUPPLIER PARETO ANALYSIS & RISK CONCENTRATION (Using Window Functions)
-- Objective: Identify which suppliers make up the top % of spend and assess their 
-- risk profiles using cumulative distributions.
-- =================================================================================
WITH SupplierSpend AS (
    SELECT 
        Supplier,
        Risk_Rating,
        Total_Spend_USD_M,
        On_Time_Delivery_Pct,
        Quality_PPM,
        SUM(Total_Spend_USD_M) OVER () AS Global_Total_Spend,
        SUM(Total_Spend_USD_M) OVER (ORDER BY Total_Spend_USD_M DESC) AS Cumulative_Spend
    FROM 
        Supplier_Scorecard
)
SELECT 
    Supplier,
    Risk_Rating,
    Total_Spend_USD_M,
    On_Time_Delivery_Pct,
    Quality_PPM,
    ROUND((Total_Spend_USD_M / Global_Total_Spend) * 100, 2) AS Pct_Of_Global_Spend,
    ROUND((Cumulative_Spend / Global_Total_Spend) * 100, 2) AS Cumulative_Spend_Pct,
    CASE 
        WHEN (Cumulative_Spend / Global_Total_Spend) <= 0.80 THEN 'Top 80% Spend (Tier 1)'
        ELSE 'Bottom 20% Spend (Tier 2)'
    END AS Spend_Tier
FROM 
    SupplierSpend
ORDER BY 
    Total_Spend_USD_M DESC;


-- =================================================================================
-- 2. INVENTORY DEPLETION & CRITICAL SHORTAGE FORECASTING (Multi-Table JOIN)
-- Objective: Cross-reference on-hand inventory with supplier lead times to flag 
-- parts that will stock out before new replenishment orders can arrive.
-- =================================================================================
SELECT 
    i.Part_Name,
    i.Region,
    p.Supplier,
    p.Lead_Time_Weeks,
    i.On_Hand_Units,
    i.On_Order_Units,
    i.Weekly_Burn_Rate,
    i.Coverage_Weeks,
    (i.Coverage_Weeks - p.Lead_Time_Weeks) AS Coverage_vs_Lead_Time_Delta,
    CASE 
        WHEN (i.Coverage_Weeks - p.Lead_Time_Weeks) < 0 THEN 'CRITICAL: Stockout Imminent'
        WHEN (i.Coverage_Weeks - p.Lead_Time_Weeks) BETWEEN 0 AND 2 THEN 'WARNING: High Risk'
        ELSE 'HEALTHY'
    END AS Stockout_Risk_Status
FROM 
    Inventory_Coverage i
INNER JOIN 
    Parts_Master p ON i.Part_ID = p.Part_ID
WHERE 
    i.Shortage_Risk IN ('HIGH', 'CRITICAL')
ORDER BY 
    Coverage_vs_Lead_Time_Delta ASC;


-- =================================================================================
-- 3. PURCHASE ORDER FULFILLMENT & DELAY BUCKETING (Conditional Aggregation)
-- Objective: Categorize PO delays into severity buckets to evaluate factory and 
-- region-level logistics bottlenecks.
-- =================================================================================
WITH PODelayMetrics AS (
    SELECT 
        Region,
        Factory,
        PO_Number,
        Total_Value_USD,
        Days_Late,
        CASE 
            WHEN Days_Late <= 0 THEN 'On Time'
            WHEN Days_Late BETWEEN 1 AND 7 THEN '1-7 Days Late'
            WHEN Days_Late BETWEEN 8 AND 14 THEN '8-14 Days Late'
            ELSE '15+ Days Late (Severe)'
        END AS Delay_Bucket
    FROM 
        Purchase_Orders
    WHERE 
        Status = 'Delayed'
)
SELECT 
    Region,
    Factory,
    COUNT(PO_Number) AS Total_Delayed_POs,
    SUM(Total_Value_USD) AS Value_Delayed_USD,
    SUM(CASE WHEN Delay_Bucket = '1-7 Days Late' THEN 1 ELSE 0 END) AS Delay_1_7_Days,
    SUM(CASE WHEN Delay_Bucket = '8-14 Days Late' THEN 1 ELSE 0 END) AS Delay_8_14_Days,
    SUM(CASE WHEN Delay_Bucket = '15+ Days Late (Severe)' THEN 1 ELSE 0 END) AS Delay_Severe,
    ROUND(AVG(Days_Late), 1) AS Avg_Days_Late
FROM 
    PODelayMetrics
GROUP BY 
    Region, 
    Factory
ORDER BY 
    Value_Delayed_USD DESC;


-- =================================================================================
-- 4. DEMAND FORECAST VARIANCE & VOLATILITY RANKING (Ranking Functions)
-- Objective: Analyze forecasting accuracy across Programs A-E. Uses ROW_NUMBER() 
-- to isolate the single most volatile part contributing to demand errors per program.
-- =================================================================================
WITH VarianceRankings AS (
    SELECT 
        Program,
        Part_Name,
        SUM(Forecast_Qty) AS Total_Forecast,
        SUM(Actual_Demand) AS Total_Actual,
        ABS(SUM(Actual_Demand) - SUM(Forecast_Qty)) AS Absolute_Variance,
        ROUND((ABS(SUM(Actual_Demand) - SUM(Forecast_Qty)) / NULLIF(SUM(Forecast_Qty), 0)) * 100, 2) AS Volatility_Pct,
        ROW_NUMBER() OVER(PARTITION BY Program ORDER BY ABS(SUM(Actual_Demand) - SUM(Forecast_Qty)) DESC) AS Volatility_Rank
    FROM 
        Demand_Forecast
    GROUP BY 
        Program, 
        Part_Name
)
SELECT 
    Program,
    Part_Name AS Most_Volatile_Part,
    Total_Forecast,
    Total_Actual,
    Absolute_Variance AS Unit_Variance,
    Volatility_Pct
FROM 
    VarianceRankings
WHERE 
    Volatility_Rank = 1
ORDER BY 
    Volatility_Pct DESC;


-- =================================================================================
-- 5. NPI (NEW PRODUCT INTRODUCTION) MILESTONE ATTAINMENT
-- Objective: Track execution status for new program launches, identifying milestone 
-- completion rates and sourcing diversity across different global regions.
-- =================================================================================
SELECT 
    Program,
    Region,
    COUNT(Milestone) AS Total_Milestones,
    SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) AS Completed_Milestones,
    SUM(CASE WHEN Clean_Launch = 'Yes' THEN 1 ELSE 0 END) AS Clean_Launches,
    ROUND(AVG(Multi_Source_Pct), 2) AS Avg_Sourcing_Diversity_Pct,
    ROUND((SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) * 100.0) / NULLIF(COUNT(Milestone), 0), 2) AS Completion_Rate_Pct
FROM 
    NPI_Program_Tracker
GROUP BY 
    Program, 
    Region
HAVING 
    COUNT(Milestone) > 0
ORDER BY 
    Completion_Rate_Pct ASC, 
    Avg_Sourcing_Diversity_Pct ASC;
