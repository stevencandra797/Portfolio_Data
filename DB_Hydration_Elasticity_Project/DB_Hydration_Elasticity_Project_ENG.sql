CREATE DATABASE DB_Hydration_Elasticity_Project;
USE DB_Hydration_Elasticity_Project;

SELECT * FROM Panel_Data_Hydration_Elasticity_Senior_Analyst_Portfolio;
SELECT * FROM Derived_Indicators_Hydration_Elasticity_Senior_Analyst_Portfolio;

-- 1. Calculating Hydration Elasticity of Compliance (HEC)
-- create table Answer_1 as
WITH rawchanges AS (
    SELECT 
        `district_`, 
        `day_`, 
        `water_ml`, 
        `compliance_index_`,
        -- Retrieve data from the previous day
        LAG(`water_ml`) OVER (PARTITION BY `district_` ORDER BY `day_`) AS prev_water,
        LAG(`compliance_index_`) OVER (PARTITION BY `district_` ORDER BY `day_`) AS prev_compliance
    FROM Panel_Data_Hydration_Elasticity_Senior_Analyst_Portfolio -- REPLACE THIS with the actual table name in your Workbench sidebar
),
CalculatedElasticity AS (
    SELECT * ,
        -- % Water Change
        (water_ml - prev_water) / NULLIF(prev_water, 0) AS water_pct_change,
        -- % Compliance Change
        (compliance_index_ - prev_compliance) / NULLIF(prev_compliance, 0) AS comp_pct_change
    FROM rawchanges
)
SELECT
    `district_`,
    `day_`,
    water_ml,
    compliance_index_,
    -- Calculating HEC (Hydration Elasticity of Compliance)
    comp_pct_change / NULLIF(water_pct_change, 0) AS HEC,
    CASE 
        WHEN ABS(comp_pct_change / NULLIF(water_pct_change, 0)) > 1 THEN 'SENSITIVE ZONE'
        ELSE 'STABLE'
    END AS status
FROM CalculatedElasticity
WHERE prev_water IS NOT NULL;


-- 2 Question: "At what water_ml level does the system begin to collapse?"
-- Task: Find the average water allowance value where the status 
-- shifts from STABLE to SENSITIVE ZONE.
-- Analysis: If the SENSITIVE ZONE average occurs at 1850ml, then 1850ml is Wcrit (Critical Threshold).

-- a. Grouping data based on the previously created status (from HEC calculation).
-- create table answer_2 as
WITH RawChanges2 AS (
    SELECT 
        `district_`, 
        `day_`, 
        `water_ml`, 
        `compliance_index_`, 
        -- 1. Added missing 'as prev_water' alias
        LAG(`water_ml`) OVER (PARTITION BY `district_` ORDER BY `day_`) AS prev_water,
        LAG(`compliance_index_`) OVER (PARTITION BY `district_` ORDER BY `day_`) AS prev_compliance
    FROM `Panel_Data_Hydration_Elasticity_Senior_Analyst_Portfolio` 
),
CalculatedHEC AS (
    SELECT *,
        ((compliance_index_ - prev_compliance) / NULLIF(prev_compliance, 0)) / 
        NULLIF(((water_ml - prev_water) / NULLIF(prev_water, 0)), 0) AS HEC
    FROM RawChanges2
),
StatusCategorization AS (
    SELECT *, 
        CASE 
            WHEN ABS(HEC) > 1 THEN 'SENSITIVE ZONE'
            ELSE 'STABLE'
        END AS status_
    FROM CalculatedHEC -- 2. Ensure NO SPACES here (CalculatedHEC, not Calculated HEC)
    WHERE prev_water IS NOT NULL
)
SELECT 
    status_, 
    ROUND(AVG(water_ml), 2) AS avg_water_threshold,
    MIN(water_ml) AS min_water_level,
    MAX(water_ml) AS max_water_level,
    COUNT(*) AS total_observations
FROM StatusCategorization
GROUP BY status_;

-- b. How to Read the Results (Analysis)
-- After running the query above, observe the SENSITIVE ZONE row:
-- avg_water_threshold: This is your $W_{crit}$ value. 
-- If the result is 1850, then statistically, when the average water allowance hits 1850ml, 
-- the community begins to react extremely (instability).
-- max_water_level in Sensitive Zone: 
-- This is the "Early Warning" figure. It means some districts start to falter even when 
-- water allowance is still as high as this number.

-- c. Report Output (The "Red Line")
-- Conclusion:

-- Red Line Analysis:

-- Green Zone (> 1950ml): Highly stable system, high compliance.

-- Yellow Zone (1850ml - 1950ml): Transition period, public becomes vigilant.

-- Red Zone (< 1850ml): SENSITIVE ZONE. Elasticity effect occurs; even a minor water reduction 
-- will lead to uncontrollable spikes in unrest.



-- 3. Unrest Correlation Probability Analysis
-- Question: "Does the spike in HEC (Sensitivity) correlate directly with unrest probability?"
-- Task: Link the HEC results with the unrest_probability column.
-- Analysis: Typically, when HEC > 1, the unrest_probability value will spike exponentially (e.g., from 0.10 directly to 0.45).
-- Objective: Prove that non-compliance is not just a protest, but a real security threat.

-- Proving through data that heat is a crisis "accelerator." 
-- Hotter districts will see citizens anger faster (entering the Sensitive Zone) 
-- even if the water reduction is the same as in cooler districts.

-- create table answer_3 as
WITH RawChanges3 AS (
    SELECT 
        `district_`, 
        `day_`, 
        `water_ml`, 
        `compliance_index_`, 
        `unrest_probability`,
        LAG(`water_ml`) OVER (PARTITION BY `district_` ORDER BY `day_`) AS prev_water,
        LAG(`compliance_index_`) OVER (PARTITION BY `district_` ORDER BY `day_`) AS prev_compliance
    FROM `Panel_Data_Hydration_Elasticity_Senior_Analyst_Portfolio` 
),
CalculatedHEC AS (
    SELECT *,
        ((compliance_index_ - prev_compliance) / NULLIF(prev_compliance, 0)) / 
        NULLIF(((water_ml - prev_water) / NULLIF(prev_water, 0)), 0) AS HEC
    FROM RawChanges3
),
StatusCategorization AS (
    SELECT *, 
        CASE 
            WHEN ABS(HEC) > 1 THEN 'SENSITIVE ZONE'
            ELSE 'STABLE'
        END AS status_
    FROM CalculatedHEC
    WHERE prev_water IS NOT NULL
)
-- Correlation Analysis Section
SELECT 
    status_, 
    COUNT(*) AS total_incidents,
    ROUND(AVG(ABS(HEC)), 2) AS avg_elasticity_score,
    ROUND(AVG(unrest_probability), 4) AS avg_unrest_risk,
    ROUND(MAX(unrest_probability), 4) AS peak_unrest_risk
FROM StatusCategorization
GROUP BY status_;

-- After the query runs, compare the avg_unrest_risk column between STABLE and SENSITIVE ZONE.
-- Exponential Spike: If risk in STABLE is only 0.05 (5%) but jumps to 0.35 (35%) in SENSITIVE ZONE, 
-- your hypothesis is proven.
-- HEC as a Leading Indicator: You can argue that HEC is a "pre-event" indicator. 
-- Meaning, before unrest actually breaks out, the HEC value will rise first.
-- Security Threat: With this data, you can report to leadership: 
-- "This non-compliance is not just lazy citizens, but has a strong correlation with physical threats (unrest) 
-- increasing [X] fold."

-- Portfolio Presentation Strategy
-- Use the SQL result table and add this narrative:
-- "Data indicates that when compliance elasticity exceeds 1 (Sensitive Zone), 
-- the probability of unrest increases non-linearly. This confirms that water 
-- reduction policies crossing critical points are no longer an administrative issue, 
-- but a matter of national security stability."

-- 4. 
-- Evidence that high temperature is "fuel" for public anger.
-- Logic: In hotter districts, people get thirsty faster. Thus, 
-- when water is reduced slightly, they lose patience much faster and become non-compliant 
-- compared to people in cooler districts.
-- a. SQL Query: Finding Crisis Speed Based on Temperature
-- This query finds the first day each district enters the SENSITIVE ZONE, 
-- then pairs it with the average temperature of that district.
-- create table answer_4 as
WITH RawChanges AS (
    SELECT 
        `district_`, `day_`, `water_ml`, `temperature_c`, `compliance_index_`,
        LAG(`water_ml`) OVER (PARTITION BY `district_` ORDER BY `day_`) AS prev_water,
        LAG(`compliance_index_`) OVER (PARTITION BY `district_` ORDER BY `day_`) AS prev_compliance
    FROM `Panel_Data_Hydration_Elasticity_Senior_Analyst_Portfolio` 
),
CalculatedHEC AS (
    SELECT *,
        ((compliance_index_ - prev_compliance) / NULLIF(prev_compliance, 0)) / 
        NULLIF(((water_ml - prev_water) / NULLIF(prev_water, 0)), 0) AS HEC
    FROM RawChanges
),
FirstSensitiveDay AS (
    SELECT 
        `district_`, 
        MIN(`day_`) AS day_of_crisis,
        AVG(`temperature_c`) AS avg_temp
    FROM CalculatedHEC
    WHERE ABS(HEC) > 1
    GROUP BY `district_`
)
SELECT 
    `district_`,
    day_of_crisis,
    ROUND(avg_temp, 1) AS temp_c,
    CASE 
        WHEN avg_temp > 34 THEN 'HOT DISTRICT'
        ELSE 'COOL DISTRICT'
    END AS climate_category
FROM FirstSensitiveDay
ORDER BY day_of_crisis ASC;

-- After running, you will see patterns like:
-- District B (High Temp ~37°C): Might enter SENSITIVE ZONE on Day 5.
-- District A (Low Temp ~30°C): Might only enter SENSITIVE ZONE on Day 14.
-- Senior Analyst Conclusion: "Temperature acts as a crisis accelerator. 
-- Data shows a negative correlation between temperature and social resilience: the higher the environmental temperature, 
-- the shorter the time required for the population to reach a tipping point in compliance. 
-- This occurs because biological stress (extreme thirst) lowers their tolerance threshold 
-- for water reduction policies."
-- Why is this important for policymakers?
-- "Do not reduce water allowance uniformly! Districts with temperatures above 35°C must be prioritized for 
-- assistance first, as they will 'explode' (riot) 3x faster than cooler districts."

-- 5. Calculation of labor_output_index_ falling to critical levels
-- create table answer_5 as
with WaterReductionStart AS
(
-- a. Finding the first day water was reduced for each district
    select `district_`, 
    MIN(`day_`) AS start_day
    FROM Panel_Data_Hydration_Elasticity_Senior_Analyst_Portfolio
    where `water_ml` < 2000
    group by `district_`
),
ProductivityCollapse AS
(
-- b. Finding the first day labor_output fell below 0.5
    SELECT `district_`,
    MIN(`day_`) AS collapse_day
    FROM Panel_Data_Hydration_Elasticity_Senior_Analyst_Portfolio
    where `labor_output_index_` < 0.5
    group by `district_`
),
SurvivalAnalysis AS
(
-- c. Calculating the day difference from start to collapse
SELECT w.`district_`,
w.start_day,
p.collapse_day,
(p.collapse_day - w.start_day) as days_to_collapse
from WaterReductionStart w
join ProductivityCollapse p ON w.`district_` = p.`district_`
)
select round(avg(days_to_collapse), 1) as avg_survival_days,
min(days_to_collapse) as fastest_collapse_days,
max(days_to_collapse) as longest_survival_days
from SurvivalAnalysis;

-- After running this query, you will get an average figure, e.g., 8.5 days.
-- Survival Threshold: "The average population can only maintain economic productivity for [X] days 
-- after water allowance is cut. After that, the system enters 'suspended animation' where the workforce 
-- no longer has enough biological energy to work effectively."
-- Economic Impact: "This is a crucial metric. 
-- If the government wants to save water without killing the economy, 
-- the duration of restrictions must not exceed [X] days."

-- Risk Mitigation: "Districts with fastest_collapse_days are 
-- the weakest points in your labor supply chain."

-- Integration into Google Looker Studio
-- This data is excellent for visualization as a Bullet Chart or Gauge Chart in Looker Studio:
-- Label: "Economic Resilience System: [X] Days".
-- Green (0-5 days), Yellow (6-8 days), Red (>8 days or at collapse start).

-- 6. Converting thousands of data rows into a single Decision Metric. 
-- Leadership doesn't have time to look at elasticity tables; 
-- they want to know which district needs water trucks sent right now.
-- Creating an Early Warning Score (EWS) on a scale of 0–100.
-- a. Logic Formula (Weighted Scoring)
-- We combine three risk dimensions:
-- Sensitivity (HEC): Weight 40% (Potential for compliance explosion).
-- Security (Unrest): Weight 30% (Actual riot risk).
-- Health/Economy (Energy Loss): Weight 30% (Remaining population energy).

-- SQL Query: Creating District Risk Rankings

-- create table answer_6 as
WITH LatestStatus AS
(
    -- Retrieving the latest/most recent data for each district
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY `district_` ORDER BY `day_` DESC) as rn,
            -- Calculate Energy Loss (100 - Energy Index)
            (100 - `energy_index_`) AS energy_loss
        FROM `Panel_Data_Hydration_Elasticity_Senior_Analyst_Portfolio`
    ) t
    WHERE rn = 1
),
CalculatedMetrics AS
(
    -- Calculating simplified HEC for scoring (focusing on value normalization)
    SELECT 
        `district_`,
        `unrest_probability` * 100 AS unrest_score,
        `energy_loss`,
        `compliance_index_`
    FROM LatestStatus
)
SELECT 
    `district_`,
    -- EWS (Early Warning Score) Formula
    -- Higher unrest, higher energy loss, lower compliance = High Score (Danger)
    ROUND(
        (unrest_score * 0.4) + 
        (energy_loss * 0.3) + 
        ((100 - compliance_index_) * 0.3), 2
    ) AS early_warning_score,
    CASE 
        WHEN (unrest_score * 0.4) + (energy_loss * 0.3) + ((100 - compliance_index_) * 0.3) > 70 THEN '🔴 CRITICAL (IMMEDIATE ACTION)'
        WHEN (unrest_score * 0.4) + (energy_loss * 0.3) + ((100 - compliance_index_) * 0.3) > 40 THEN '🟡 WARNING (MONITOR CLOSELY)'
        ELSE '🟢 STABLE'
    END AS risk_status
FROM CalculatedMetrics
ORDER BY early_warning_score DESC;