-- +goose Up
-- SQL in this section is executed when the migration is applied.
ALTER TABLE transactions
    ADD COLUMN service_id UUID NOT NULL REFERENCES services(id) ON DELETE RESTRICT;

CREATE INDEX IF NOT EXISTS idx_transactions_service_id ON transactions(service_id);

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.
DROP INDEX IF EXISTS idx_transactions_service_id;
ALTER TABLE transactions DROP COLUMN IF EXISTS service_id;

