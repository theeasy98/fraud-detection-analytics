-- ============================================================
-- PHASE 2: FEATURE ENGINEERING
-- Adds merchant risk and location risk scoring to the cleaned table
-- ============================================================

CREATE OR REPLACE TABLE `creditcard-frauddetetction.creditcardfrauddetetction.fraud_analysis` AS

WITH merchant_risk AS (
  SELECT
    MerchantID,
    COUNT(*)                                    AS merchant_total_txns,
    SUM(IsFraud)                                AS merchant_fraud_count,
    ROUND(AVG(IsFraud) * 100, 2)               AS merchant_fraud_rate,
    CASE
      WHEN AVG(IsFraud) >= 0.05 THEN 'High Risk'
      WHEN AVG(IsFraud) >= 0.02 THEN 'Medium Risk'
      ELSE 'Low Risk'
    END                                         AS merchant_risk_level
  FROM `creditcard-frauddetetction.creditcardfrauddetetction.clean_transactions`
  GROUP BY MerchantID
),

location_risk AS (
  SELECT
    Location,
    COUNT(*)                                    AS location_total_txns,
    SUM(IsFraud)                                AS location_fraud_count,
    ROUND(AVG(IsFraud) * 100, 2)               AS location_fraud_rate
  FROM `creditcard-frauddetetction.creditcardfrauddetetction.clean_transactions`
  GROUP BY Location
)

SELECT
  c.*,
  m.merchant_total_txns,
  m.merchant_fraud_count,
  m.merchant_fraud_rate,
  m.merchant_risk_level,
  l.location_total_txns,
  l.location_fraud_count,
  l.location_fraud_rate,

  -- Final enriched risk score (0-100)
  ROUND(
    c.fraud_risk_score +
    (CASE WHEN m.merchant_risk_level = 'High Risk'   THEN 20 ELSE 0 END) +
    (CASE WHEN m.merchant_risk_level = 'Medium Risk' THEN 10 ELSE 0 END) +
    (CASE WHEN l.location_fraud_rate > 1.5           THEN 15 ELSE 0 END)
  , 0)                                              AS enriched_risk_score

FROM `creditcard-frauddetetction.creditcardfrauddetetction.clean_transactions` c
LEFT JOIN merchant_risk  m ON c.MerchantID = m.MerchantID
LEFT JOIN location_risk  l ON c.Location   = l.Location;
