-- Governed KPI definitions (see docs/metric_dictionary.md). Each block is reconciled to the Python
-- output by src/s11_sql_layer.py. Dialect notes are given where Postgres differs from SQLite.

-- name: monthly_kpis
-- Active card = at least one cleaned, positive-amount transaction in the calendar month.
SELECT CAST(substr(t.txn_date, 6, 2) AS INTEGER)                      AS month,
       COUNT(DISTINCT t.customer_id)                                  AS active_cards,
       COUNT(*)                                                       AS txn_count,
       SUM(t.amount)                                                  AS spend_inr,
       ROUND(SUM(t.amount) * 1.0 / COUNT(DISTINCT t.customer_id), 1)  AS spend_per_active
FROM transactions t
GROUP BY 1
ORDER BY 1;

-- name: activation_30d_by_issue_month
-- Activation = first transaction within 30 days of issue date; 2025 issue cohorts only.
-- Postgres: replace julianday(a) - julianday(b) with (a::date - b::date).
WITH first_txn AS (
    SELECT customer_id, MIN(txn_date) AS first_txn FROM transactions GROUP BY customer_id
)
SELECT CAST(substr(c.issue_date, 6, 2) AS INTEGER) AS issue_month,
       COUNT(*)                                    AS cards_issued,
       SUM(CASE WHEN f.first_txn IS NOT NULL
                 AND julianday(f.first_txn) - julianday(c.issue_date) <= 30 THEN 1 ELSE 0 END) AS activated_30d,
       ROUND(100.0 * SUM(CASE WHEN f.first_txn IS NOT NULL
                 AND julianday(f.first_txn) - julianday(c.issue_date) <= 30 THEN 1 ELSE 0 END) / COUNT(*), 2) AS activation_30d_pct
FROM customers c
LEFT JOIN first_txn f ON f.customer_id = c.customer_id
WHERE substr(c.issue_date, 1, 4) = '2025'
GROUP BY 1
ORDER BY 1;

-- name: quarterly_retention
-- Retention = share of cards active in quarter Q that are also active in Q+1.
WITH q AS (
    SELECT customer_id, (CAST(substr(txn_date, 6, 2) AS INTEGER) - 1) / 3 + 1 AS qtr
    FROM transactions
    GROUP BY customer_id, qtr
)
SELECT a.qtr                                                AS from_q,
       COUNT(*)                                             AS active_base,
       COUNT(b.customer_id)                                 AS retained,
       ROUND(100.0 * COUNT(b.customer_id) / COUNT(*), 2)    AS retention_pct
FROM q a
LEFT JOIN q b ON b.customer_id = a.customer_id AND b.qtr = a.qtr + 1
WHERE a.qtr < 4
GROUP BY a.qtr
ORDER BY a.qtr;
