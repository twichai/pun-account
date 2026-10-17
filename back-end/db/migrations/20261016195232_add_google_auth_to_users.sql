-- +goose Up
-- SQL in this section is executed when the migration is applied.

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS google_id VARCHAR(255) UNIQUE;

CREATE INDEX IF NOT EXISTS idx_users_google_id ON users (google_id);

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.

DROP INDEX IF EXISTS idx_users_google_id;

ALTER TABLE users
    DROP COLUMN IF EXISTS google_id;

