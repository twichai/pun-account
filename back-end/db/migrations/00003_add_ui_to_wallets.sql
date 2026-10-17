-- +goose Up
-- SQL in this section is executed when the migration is applied.

ALTER TABLE wallets
    ADD COLUMN IF NOT EXISTS currency VARCHAR(10) NOT NULL DEFAULT 'THB',
    ADD COLUMN IF NOT EXISTS ui JSONB NOT NULL DEFAULT '{}'::jsonb;

-- GIN index on UI JSONB for query performance when filtering by UI properties
CREATE INDEX IF NOT EXISTS idx_wallets_ui ON wallets USING gin (ui);

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.

DROP INDEX IF EXISTS idx_wallets_ui;

ALTER TABLE wallets
    DROP COLUMN IF EXISTS ui,
    DROP COLUMN IF EXISTS currency;
