-- name: spend_concentration_deciles
-- Window functions: how concentrated is Jan-Sep spend across active customers?
WITH s AS (
    SELECT customer_id, SUM(amount) AS spend
    FROM transactions
    WHERE CAST(substr(txn_date, 6, 2) AS INTEGER) <= 9
    GROUP BY customer_id
), r AS (
    SELECT customer_id, spend, NTILE(10) OVER (ORDER BY spend DESC) AS spend_decile FROM s
)
SELECT spend_decile,
       COUNT(*)                                                    AS customers,
       ROUND(SUM(spend), 0)                                        AS spend,
       ROUND(100.0 * SUM(spend) / SUM(SUM(spend)) OVER (), 1)      AS pct_of_spend
FROM r
GROUP BY spend_decile
ORDER BY spend_decile;

-- name: card_x_category_margin
-- Net margin = interchange (MDR) - rewards - loss assumption (0.15% of spend, see common.py).
SELECT c.card_type,
       m.merchant_category,
       ROUND(SUM(t.amount), 0)                                                         AS spend,
       ROUND(100.0 * SUM(t.amount * (r.mdr_rate - w.reward_rate - 0.0015)) / SUM(t.amount), 2) AS net_margin_pct_of_spend
FROM transactions t
JOIN customers   c ON c.customer_id       = t.customer_id
JOIN merchants   m ON m.merchant_id       = t.merchant_id
JOIN ref_mdr     r ON r.merchant_category = m.merchant_category
JOIN ref_reward  w ON w.card_type         = c.card_type
GROUP BY c.card_type, m.merchant_category
ORDER BY c.card_type, m.merchant_category;

-- name: total_interchange
SELECT ROUND(SUM(t.amount * r.mdr_rate), 0) AS interchange_inr
FROM transactions t
JOIN merchants m ON m.merchant_id = t.merchant_id
JOIN ref_mdr   r ON r.merchant_category = m.merchant_category;

-- name: top_merchants_by_gmv
SELECT t.merchant_id, m.merchant_category, m.merchant_size,
       COUNT(*) AS txns, COUNT(DISTINCT t.customer_id) AS customers, ROUND(SUM(t.amount), 0) AS gmv
FROM transactions t
JOIN merchants m ON m.merchant_id = t.merchant_id
GROUP BY t.merchant_id, m.merchant_category, m.merchant_size
ORDER BY gmv DESC
LIMIT 20;
