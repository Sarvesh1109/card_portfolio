# Metric dictionary and governance standards

One definition per metric, used identically in Python (`src/`), SQL (`sql/`) and DAX (`powerbi/measures.dax`).
`src/s11_sql_layer.py` fails the pipeline if the SQL and Python answers disagree.

## Population rules (apply to every metric)
* **Source:** cleaned transactions only (`data/processed/transactions_clean.csv`) — duplicates removed, reversals (amount ≤ 0) and suspected unit errors (amount > ₹200,000) excluded, with the raw→clean reconciliation in `outputs/tables/dq_reconciliation.csv`.
* **Calendar:** transactions are assigned to a month by `txn_date`; all dates are ISO `yyyy-mm-dd`, no time zones.
* **Currency:** INR, no conversion.

## Portfolio KPIs

| Metric | Definition | Grain | Notes |
|---|---|---|---|
| Cards issued (cumulative) | Cards with `issue_date` ≤ month end | month | Denominator for active rate |
| Active card | Card with ≥ 1 cleaned transaction in the calendar month | card × month | |
| Active rate | Active cards ÷ cards issued (cumulative) | month | |
| Spend | Σ cleaned `amount` | any | Gross, before reversals |
| Spend per active card | Spend ÷ active cards | month | |
| Txns per active card | Transaction count ÷ active cards | month | |
| Average ticket | Spend ÷ transaction count | any | |
| E-commerce share | Spend with `channel = 'ECOM'` ÷ spend | any | |
| 30-day activation | Cards whose first transaction is ≤ 30 days after `issue_date` ÷ cards issued | issue month | 2025 issue cohorts only (earlier cohorts have no issue-time history in the window) |
| Quarterly retention | Cards active in quarter Q that are also active in Q+1 ÷ cards active in Q | quarter | Activity-based definition |
| Quarterly attrition | 1 − quarterly retention | quarter | |
| Model attrition (label) | Card active in Apr–Jun with **zero** transactions in Jul–Sep | card | Used by `s06`; features use Jan–Jun only |

## Segmentation definitions
| Segment | Rule |
|---|---|
| Persona | K-Means on log transactions, log ticket, e-commerce share and 8 category shares for cards with ≥ 3 transactions (Jan–Sep); k chosen by silhouette in 4–7; names assigned by documented centroid rules |
| Value tier | Rank of Jan–Sep spend among cards with spend: A = top 10%, B = next 20%, C = next 30%, D = bottom 40% |
| Lifecycle | *Not activated* (no txn) → *New* (tenure < 3 m) → *Lapsing/dormant* (last txn > 60 days before 30-Sep) → *At-risk* (trend ratio < 0.5 or last txn > 30 days) → *Growing* (trend ratio > 1.5) → *Stable* |
| Trend ratio | (txns in last 2 months ÷ 2 + 0.5) ÷ (txns per month before that + 0.5) |
| Merchant class | ABC on cumulative GMV (A = first 50%, B = next 30%, C = last 20%) × momentum (growth index ≥ 1.15 outgrowing, ≤ 0.85 lagging, else in line); growth index = merchant H2/H1 GMV ÷ portfolio H2/H1 GMV |

## Economics
| Metric | Definition |
|---|---|
| Interchange income | Σ amount × MDR rate by merchant category (`MDR_BY_CATEGORY`) |
| Rewards cost | Σ amount × reward rate by card type (`REWARD_RATE_BY_CARD`) |
| Loss | Spend × 0.15% (assumption) |
| Cost to serve | ₹3 per card-month held + ₹12 per active card-month |
| Contribution | Interchange + fees − rewards − loss − cost to serve − campaign reward cost |
| Net margin on spend | (Interchange − rewards − loss) ÷ spend |
| Break-even spend lift | Δreward ÷ (current net margin − Δreward) |

## Test-and-learn standards
* Randomise inside a pre-defined eligible base; store assignment (`campaign_assignment.csv`) before outcomes exist.
* Check balance (|standardised mean difference| < 0.1) before reading any result.
* Primary outcome: spend in the outcome window; report CI, not just a p-value.
* Use pre-period spend as a CUPED covariate to cut variance; state the variance reduction.
* ROI counts the reward paid to people who would have qualified anyway (deadweight).

## Governance checklist for any new analytical asset
1. Add the metric here with grain, filters and owner.
2. Re-implement it independently (SQL vs Python) and reconcile.
3. Add it to `feature_catalog.md` if it is a model input, with its window (no look-ahead).
4. Put every business assumption in `src/common.py`, never inside a script.
5. Run `python run_all.py`; the DQ gate and reconciliation must pass.
