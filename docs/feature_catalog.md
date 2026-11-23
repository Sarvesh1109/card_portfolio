# Feature catalog (customer snapshot tables)

Built by `build_features(win_start, win_end)` in `src/s03_build_features.py`. Two snapshots are produced:
`features_h1.csv` (Jan–Jun, as of 30-Jun — attrition and cross-sell models) and `features_sep.csv`
(Jan–Sep, as of 30-Sep — segmentation, campaign analysis). Features use **only** transactions inside the window.

| Feature | Type | Definition |
|---|---|---|
| txn_cnt | count | Transactions in window |
| spend | INR | Σ amount in window |
| avg_ticket / max_ticket | INR | Mean / max transaction amount |
| recency_days | days | Days from last transaction to snapshot date (999 if none) |
| active_months | count | Months with ≥ 1 transaction |
| cnt_recent2 | count | Transactions in the last 2 months of the window |
| cnt_prior_per_month | rate | Transactions per month before the last 2 months |
| trend_ratio | ratio | (cnt_recent2/2 + 0.5) ÷ (cnt_prior_per_month + 0.5); < 1 = slowing |
| spend_cv | ratio | Std ÷ mean of monthly spend (zero months included) |
| ecom_share | share | E-commerce spend ÷ spend |
| n_categories | count | Distinct merchant categories used |
| share_<category> | share | Spend share in each of 8 categories |
| top_cat_share | share | Largest single-category share |
| lifestyle_share | share | Dining + Travel + Electronics |
| essential_share | share | Grocery + Fuel + Utilities + Healthcare |
| tenure_months | months | Snapshot date − issue date |
| card_type, income_band, age_band, acquisition_channel, issuer_bank, city_tier | static | Attributes from `customers` (card type as of Jan-2025) |

## Labels (never used as features)
| Label | Table | Definition |
|---|---|---|
| attrited | `attrition_scores.csv` | Active Apr–Jun, zero transactions Jul–Sep |
| upgraded | `crosssell_scores.csv` | Premium-upgrade event dated Jul–Dec |
| group / y | `campaign_scored.csv` | Randomised assignment / Oct–Nov spend |

## Model scores published to downstream users
| File | Columns | Use |
|---|---|---|
| attrition_scores.csv | attrition_risk, risk_decile (1 = riskiest) | Retention targeting, dashboards |
| crosssell_scores.csv | upgrade_propensity, propensity_decile | Upgrade campaign audience |
| customer_segments.csv | persona, value_tier, lifecycle | Offer design, reporting |
| merchant_segments.csv | merchant_segment | Acquisition and partnership planning |
