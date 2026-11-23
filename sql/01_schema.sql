-- Logical schema used by the SQL layer (SQLite dialect; types map 1:1 to Postgres / SQL Server).
-- Source: data/processed/*.csv produced by the Python pipeline AFTER the data-quality gate.

CREATE TABLE customers (
    customer_id          TEXT PRIMARY KEY,
    issuer_bank          TEXT,
    card_type            TEXT,      -- Classic | Platinum | Select (as of Jan-2025)
    city_tier            INTEGER,
    age_band             TEXT,
    income_band          TEXT,
    acquisition_channel  TEXT,
    issue_date           TEXT       -- ISO yyyy-mm-dd
);

CREATE TABLE merchants (
    merchant_id        TEXT PRIMARY KEY,
    merchant_category  TEXT,
    city_tier          INTEGER,
    merchant_size      TEXT,
    onboarding_date    TEXT
);

CREATE TABLE transactions (
    txn_id       TEXT PRIMARY KEY,
    customer_id  TEXT REFERENCES customers(customer_id),
    merchant_id  TEXT REFERENCES merchants(merchant_id),
    txn_date     TEXT,              -- ISO yyyy-mm-dd
    amount       REAL,              -- INR, > 0 after cleaning
    channel      TEXT               -- POS | NFC | ECOM | UNKNOWN
);

-- Reference tables = the business ASSUMPTIONS (loaded from src/common.py so SQL and Python cannot drift)
CREATE TABLE ref_mdr    (merchant_category TEXT PRIMARY KEY, mdr_rate REAL);
CREATE TABLE ref_reward (card_type TEXT PRIMARY KEY, reward_rate REAL);

CREATE INDEX ix_txn_customer ON transactions(customer_id);
CREATE INDEX ix_txn_date     ON transactions(txn_date);
CREATE INDEX ix_txn_merchant ON transactions(merchant_id);
