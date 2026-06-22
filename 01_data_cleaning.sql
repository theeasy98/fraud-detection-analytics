-- ============================================================
-- PHASE 1: DATA CLEANING & FEATURE ENGINEERING
-- Creates a cleaned, enriched table from raw_transactions
-- ============================================================

CREATE OR REPLACE TABLE `creditcard-frauddetetction.creditcardfrauddetetction.clean_transactions` AS

SELECT
  TransactionID,
  TIMESTAMP(TransactionDate)                          AS TransactionDate,
  ROUND(Amount, 2)                                    AS Amount,
  MerchantID,
  UPPER(TRIM(TransactionType))                        AS TransactionType,
  INITCAP(TRIM(Location))                             AS Location,
  IsFraud,

  -- Time features
  EXTRACT(HOUR FROM TIMESTAMP(TransactionDate))       AS hour_of_day,
  EXTRACT(DAYOFWEEK FROM TIMESTAMP(TransactionDate))  AS day_of_week,
  FORMAT_TIMESTAMP('%A', TIMESTAMP(TransactionDate))  AS day_name,
  EXTRACT(MONTH FROM TIMESTAMP(TransactionDate))      AS month_num,
  FORMAT_TIMESTAMP('%B', TIMESTAMP(TransactionDate))  AS month_name,
  EXTRACT(QUARTER FROM TIMESTAMP(TransactionDate))    AS quarter,

  -- Amount bracket
  CASE
    WHEN Amount < 500                THEN 'Low'
    WHEN Amount BETWEEN 500 AND 1500 THEN 'Medium'
    WHEN Amount BETWEEN 1500 AND 3000 THEN 'High'
    ELSE 'Very High'
  END                                                 AS amount_bracket,

  -- Time of day segment
  CASE
    WHEN EXTRACT(HOUR FROM TIMESTAMP(TransactionDate)) BETWEEN 6  AND 11 THEN 'Morning'
    WHEN EXTRACT(HOUR FROM TIMESTAMP(TransactionDate)) BETWEEN 12 AND 17 THEN 'Afternoon'
    WHEN EXTRACT(HOUR FROM TIMESTAMP(TransactionDate)) BETWEEN 18 AND 22 THEN 'Evening'
    ELSE 'Late Night'
  END                                                 AS time_segment,

  -- Fraud risk score (rule-based, 0-100)
  ROUND(
    (CASE WHEN Amount > 3000 THEN 30 ELSE 0 END) +
    (CASE WHEN UPPER(TRIM(TransactionType)) = 'PURCHASE' THEN 20 ELSE 0 END) +
    (CASE WHEN EXTRACT(HOUR FROM TIMESTAMP(TransactionDate)) BETWEEN 0 AND 5 THEN 25 ELSE 0 END) +
    (CASE WHEN Amount > 4000 THEN 25 ELSE 0 END)
  , 0)                                                AS fraud_risk_score

FROM `creditcard-frauddetetction.creditcardfrauddetetction.raw_transactions`
WHERE
  Amount > 0
  AND TransactionID IS NOT NULL
  AND IsFraud IS NOT NULL;
