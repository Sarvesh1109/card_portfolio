"""Run the whole pipeline end to end:  python run_all.py
Total runtime is roughly 30-60 seconds on a laptop. Everything is seeded, so results are reproducible."""
import subprocess
import sys
import time
from pathlib import Path

STEPS = [
    "s01_generate_data.py",        # synthetic customers / merchants / transactions / campaign / product events (+ injected DQ issues)
    "s02_data_quality.py",         # DQ checks, cleaning rules, raw -> clean reconciliation
    "s03_build_features.py",       # fact_customer_month + point-in-time feature snapshots
    "s04_portfolio_kpis.py",       # activation, usage, spend, retention, attrition KPIs
    "s05_segmentation.py",         # personas, value tiers, lifecycle, merchant segments
    "s06_attrition_model.py",      # attrition propensity
    "s07_crosssell_model.py",      # premium-upgrade propensity
    "s08_campaign_analysis.py",    # randomised test: incremental spend, CUPED, ROI, uplift targeting
    "s09_pricing_unit_economics.py",  # customer P&L, margin structure, reward scenarios, break-even
    "s11_sql_layer.py",            # SQL KPIs reconciled to Python KPIs
    "s10_build_dashboard.py",      # Power BI exports + HTML dashboard
]

src = Path(__file__).resolve().parent / "src"
t0 = time.time()
for s in STEPS:
    t = time.time()
    print(f"\n=== {s} ===", flush=True)
    r = subprocess.run([sys.executable, str(src / s)], cwd=src)
    if r.returncode != 0:
        sys.exit(f"FAILED at {s}")
    print(f"--- {s} done in {time.time() - t:.1f}s", flush=True)
print(f"\nAll steps finished in {time.time() - t0:.0f}s. Open outputs/dashboard.html")
