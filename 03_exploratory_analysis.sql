-- ============================================================
-- PHASE 3: EXPLORATORY DATA ANALYSIS
-- Five core analysis queries answering key business questions
-- ============================================================

-- Q1: Which transaction type carries more fraud risk?
SELECT
  TransactionType,
  COUNT(*) AS total_txns,
  SUM(IsFraud) AS fraud_cases,
  ROUND(AVG(IsFraud) * 100, 2) AS fraud_rate_pct
FROM `creditcard-frauddetetction.creditcardfrauddetetction.fraud_analysis`
GROUP BY TransactionType
ORDER BY fraud_rate_pct DESC;


-- Q2: Which cities have the highest fraud rate?
SELECT
  Location,
  COUNT(*) AS total_txns,
  SUM(IsFraud) AS fraud_cases,
  ROUND(AVG(IsFraud) * 100, 2) AS fraud_rate_pct
FROM `creditcard-frauddetetction.creditcardfrauddetetction.fraud_analysis`
GROUP BY Location
ORDER BY fraud_rate_pct DESC;


-- Q3: What time of day sees the most fraud?
SELECT
  hour_of_day,
  time_segment,
  COUNT(*) AS total_txns,
  SUM(IsFraud) AS fraud_cases,
  ROUND(AVG(IsFraud) * 100, 2) AS fraud_rate_pct
FROM `creditcard-frauddetetction.creditcardfrauddetetction.fraud_analysis`
GROUP BY hour_of_day, time_segment
ORDER BY hour_of_day;


-- Q4: Are larger transactions more likely to be fraudulent?
SELECT
  amount_bracket,
  COUNT(*) AS total_txns,
  SUM(IsFraud) AS fraud_cases,
  ROUND(AVG(IsFraud) * 100, 2) AS fraud_rate_pct,
  ROUND(AVG(Amount), 2) AS avg_amount
FROM `creditcard-frauddetetction.creditcardfrauddetetction.fraud_analysis`
GROUP BY amount_bracket
ORDER BY avg_amount;


-- Q5: Which merchants carry the highest fraud risk?
SELECT
  MerchantID,
  merchant_risk_level,
  merchant_total_txns,
  merchant_fraud_count,
  merchant_fraud_rate
FROM `creditcard-frauddetetction.creditcardfrauddetetction.fraud_analysis`
GROUP BY MerchantID, merchant_risk_level, merchant_total_txns, merchant_fraud_count, merchant_fraud_rate
ORDER BY merchant_fraud_rate DESC
LIMIT 10;
