# Limitations and how to talk about this project honestly

## What this project is
A self-initiated portfolio project on **synthetic** data that demonstrates the product-analytics workflow end to end. It is not a production system and it does not contain real NPCI, bank or customer data. Date it truthfully on your resume (the month you built or finished it).

## Limitations you should state before an interviewer finds them
1. **Synthetic data is cleaner than real data.** Model AUCs (attrition ≈ 0.89) are optimistic; real feeds have messier labels and weaker signal. The cross-sell AUC (≈ 0.70) is closer to what real propensity models achieve.
2. **Because the simulation is multiplicative, absolute uplift scales with baseline spend** — so the uplift model mostly finds "big spenders", not subtle responders. With ~2,100 customers the T-learner is noisy beyond the top quintile.
3. **Personas only partly recover the hidden structure** (adjusted Rand index ≈ 0.2 against the hidden truth). Real personas should always be validated against actions a business can take, not only silhouette scores.
4. **Elasticities in the pricing scenarios are assumptions**, shown as low/base/high. The honest takeaway is the break-even lift, not the scenario outputs.
5. **Campaign ROI ignores lifetime value.** Reactivation may also reduce future attrition; a fuller analysis needs a longer observation window.
6. **No time-based validation.** The attrition and cross-sell models use a random 70/30 split of customers. With real data you would train on an earlier snapshot and test on a later one.
7. **No big-data platform, no cloud deployment, no Power BI file.** Only the Power BI-ready exports and DAX measures are provided.

## Questions to be ready for
* *Why CUPED?* Pre-period spend explains a lot of the variance in outcome spend; adjusting for it shrinks the confidence interval without biasing a randomised estimate (here variance fell 28%).
* *Why is the campaign ROI "positive" but you don't recommend a blanket rollout?* The net-value CI includes zero, ~90% of rewards were deadweight, and targeting the top uplift quintile delivers the same total value with 80% fewer rewards.
* *How do you know the SQL and Python agree?* `s11_sql_layer.py` reconciles nine KPI checks and fails the run on any mismatch.
* *How would you move this to a real portfolio?* Replace `s01` with the real extract, keep `s02`–`s11`, re-validate every assumption in `common.py` with finance, switch to time-based validation, and port the feature builder to Spark.
* *What would you do differently with more time?* Estimate elasticity from a randomised reward test, add survival/CLV modelling, and monitor model drift.

## Resume wording rules used here
* Say "synthetic" in the project line.
* Quote only numbers you can reproduce with `python run_all.py`.
* Do not claim a Power BI dashboard unless you build the .pbix yourself from the exports.
* Do not claim Spark/Databricks experience from this project.
