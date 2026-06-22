# Credit Card Fraud Detection — SQL + Tableau

I built this project to practice the full analytics workflow end to end: take raw transaction data, clean it in SQL, engineer some risk features, and turn it into a dashboard someone could actually use to spot fraud patterns.

Data: 100,000 synthetic credit card transactions (Oct 2023 – Oct 2024), 1,000 of them flagged as fraud (~1% fraud rate). SQL was done in BigQuery, dashboard in Tableau.

## What's in here

```
sql/
  01_data_cleaning.sql        - cleans raw_transactions, adds time/amount features
  02_feature_engineering.sql  - adds merchant and location risk scoring
  03_exploratory_analysis.sql - the 5 queries I used to answer the main questions
README.md
```

## The pipeline

**1. Cleaning** — cast types, pull out hour/day/month from the timestamp, bucket transaction amounts into Low/Medium/High/Very High, and build a basic rule-based risk score.

**2. Feature engineering** — for every merchant and every city, calculate their fraud rate and bucket them into Low/Medium/High risk. Joined that back onto the cleaned data to get one final table (`fraud_analysis`) that the dashboard reads from directly.

**3. Analysis** — ran 5 queries to answer the questions that actually matter for a fraud team:

| Question | What I found |
|---|---|
| Purchase or refund — which is riskier? | Pretty much tied (1.01% vs 0.99%) |
| Which cities have the worst fraud rate? | New York (1.16%), San Diego (1.14%) |
| What time of day is worst? | Two spikes — 6pm and 1am |
| Do bigger transactions get hit more? | Yes — transactions over $3k make up 40.7% of all fraud despite being a smaller slice of volume |
| Is fraud concentrated in a few bad merchants? | Not really — top 10 merchants are all sitting at 4-5 fraud cases each, no major outlier except one (merchant 640, 5.81% rate) |

## Dashboard

Connected Tableau directly to the `fraud_analysis` table in BigQuery. Main pieces:

- 4 KPI cards up top (transactions, fraud cases, fraud rate as a gauge, total fraud $) each with a small sparkline
- A bubble map of fraud by city
- A day x hour heatmap to spot when fraud clusters
- Line chart of fraud by hour with an average line
- Top 10 riskiest merchants, color coded
- Donut chart breaking fraud down by transaction amount

The one thing I'm fairly happy with: a few of the charts (the map, the hour chart, the donut) have a mini bar chart embedded right in the tooltip, so when you hover over a city or an hour it shows you the purchase/refund split for just that slice, without cluttering up the main dashboard. Took a bit of trial and error to get Tableau to filter that correctly.

## Things I'd do differently next time

- The dataset only spans about 13 months, so I couldn't do a real year-over-year comparison — settled for month-over-month trends instead
- City names like "San Antonio" / "San Diego" etc. were ambiguous for Tableau's geocoding until I added an explicit State column back in BigQuery — worth doing that from the start next time
- Would like to add a proper date-range filter that drives the whole dashboard instead of being fixed to 2024

## Reproducing this

1. Load your raw CSV into BigQuery as `raw_transactions`
2. Run `01_data_cleaning.sql`
3. Run `02_feature_engineering.sql`
4. Run the queries in `03_exploratory_analysis.sql` to sanity check the numbers
5. Point Tableau at `fraud_analysis` and rebuild from there
