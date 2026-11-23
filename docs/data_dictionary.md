# Data dictionary (raw files in `data/raw`)

All records are synthetic.

| File | Grain | Columns |
|---|---|---|
| customers.csv | one row per card | customer_id, issuer_bank (Bank_A–F), card_type (Classic/Platinum/Select), city_tier (1–3), age_band, income_band (Low/Mid/High), acquisition_channel (Branch/Digital/Co-brand partner), issue_date |
| merchants.csv | one row per merchant | merchant_id, merchant_category (8 categories), city_tier, merchant_size (Small/Medium/Large), onboarding_date |
| transactions.csv | one row per transaction | txn_id, customer_id, merchant_id, txn_date, amount (INR), channel (POS/NFC/ECOM) |
| campaign_assignment.csv | one row per eligible card | campaign_id, customer_id, group (treatment/control), send_date, offer |
| product_events.csv | one row per product event | customer_id, event_type (PREMIUM_UPGRADE), event_date |
| _hidden_truth_for_validation_only.csv | one row per card | true persona, true churn month, true uplift — **used only to sanity-check methods; never a model input** |

## Known issues deliberately injected into transactions.csv
| Issue | Rate | Treatment |
|---|---|---|
| Exact duplicate rows | ~0.15% | Drop on `txn_id` |
| Reversals (negative amount) | ~0.1% | Excluded from spend KPIs, kept in `reversals.csv` |
| ×100 unit errors (> ₹200,000) | 6 rows | Excluded, listed in `dq_suspected_unit_errors.csv` |
| Null channel | ~0.2% | Filled with `UNKNOWN` |
| Null age_band (customers) | 1% | Filled with `Unknown` |

## How the simulation works (so results can be interpreted)
* Five hidden personas drive category mix, ticket size and frequency; income, card type and city tier shift usage intensity.
* Each card has a monthly churn hazard that depends on tier, income, card type, channel, persona and tenure. Usage winds down over the two months before a card stops transacting. 4% of card-months are temporary lulls (noise).
* Seasonality lifts Oct–Dec. A randomised 75/25 reactivation offer is sent to cards with some Jul–Sep use and ≤ 3 transactions in September; the true uplift is multiplicative and differs by persona.
* Premium upgrades depend on income, spend, lifestyle share and tier, with noise.
