-- +goose Up
-- SQL in this section is executed when the migration is applied.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- UUIDv7 Generator Function (RFC 9562)
-- Uses 48-bit millisecond timestamp + 74 bits of randomness for sequential B-tree insertion.
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION gen_random_uuid_v7()
RETURNS uuid
AS $$
DECLARE
    unix_time_ms bytea;
    rand_bytes bytea;
    uuid_bytes bytea;
BEGIN
    -- 6 bytes (48 bits) of unix epoch time in milliseconds
    unix_time_ms := substring(int8send((extract(epoch from clock_timestamp()) * 1000)::bigint) from 3 for 6);
    rand_bytes := gen_random_bytes(10);
    uuid_bytes := unix_time_ms || rand_bytes;

    -- Set version to 7 (0111) at byte 6 (bits 48-51)
    uuid_bytes := set_byte(uuid_bytes, 6, (get_byte(uuid_bytes, 6) & 15) | 112);
    -- Set variant to RFC 9562 (10) at byte 8 (bits 64-65)
    uuid_bytes := set_byte(uuid_bytes, 8, (get_byte(uuid_bytes, 8) & 63) | 128);

    RETURN encode(uuid_bytes, 'hex')::uuid;
END;
$$ LANGUAGE plpgsql VOLATILE;
-- +goose StatementEnd

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS businesses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    currency VARCHAR(10) NOT NULL DEFAULT 'THB',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL, -- cash, bank, e_wallet, credit_card, other
    balance NUMERIC(15, 2) NOT NULL DEFAULT 0.00, -- Cached value; transactions are source of truth
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE, -- NULL for system default categories
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL, -- income, expense
    icon VARCHAR(100),
    parent_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    is_system BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE RESTRICT,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    type VARCHAR(50) NOT NULL, -- income, expense, owner_withdrawal, owner_contribution, transfer
    amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
    transaction_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS transfers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    from_wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE RESTRICT,
    to_wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE RESTRICT,
    amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
    transaction_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_transfers_different_wallets CHECK (from_wallet_id <> to_wallet_id)
);

CREATE TABLE IF NOT EXISTS attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    transaction_id UUID NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
    file_url TEXT NOT NULL,
    file_type VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL, -- e.g. equipment, computer, vehicle, software, other
    purchase_amount NUMERIC(15, 2) NOT NULL CHECK (purchase_amount >= 0),
    purchase_date TIMESTAMPTZ NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'active', -- active, disposed, depreciated
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_deleted_at ON users(deleted_at);
CREATE INDEX IF NOT EXISTS idx_businesses_owner_id ON businesses(owner_id);
CREATE INDEX IF NOT EXISTS idx_businesses_deleted_at ON businesses(deleted_at);
CREATE INDEX IF NOT EXISTS idx_wallets_business_id ON wallets(business_id);
CREATE INDEX IF NOT EXISTS idx_wallets_deleted_at ON wallets(deleted_at);
CREATE INDEX IF NOT EXISTS idx_categories_business_id ON categories(business_id);
CREATE INDEX IF NOT EXISTS idx_categories_parent_id ON categories(parent_id);
CREATE INDEX IF NOT EXISTS idx_categories_is_system ON categories(is_system);
CREATE INDEX IF NOT EXISTS idx_categories_deleted_at ON categories(deleted_at);
CREATE INDEX IF NOT EXISTS idx_transactions_business_date ON transactions(business_id, transaction_date DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_wallet_id ON transactions(wallet_id);
CREATE INDEX IF NOT EXISTS idx_transactions_category_id ON transactions(category_id);
CREATE INDEX IF NOT EXISTS idx_transactions_deleted_at ON transactions(deleted_at);
CREATE INDEX IF NOT EXISTS idx_transfers_business_date ON transfers(business_id, transaction_date DESC);
CREATE INDEX IF NOT EXISTS idx_transfers_from_wallet_id ON transfers(from_wallet_id);
CREATE INDEX IF NOT EXISTS idx_transfers_to_wallet_id ON transfers(to_wallet_id);
CREATE INDEX IF NOT EXISTS idx_transfers_deleted_at ON transfers(deleted_at);
CREATE INDEX IF NOT EXISTS idx_attachments_transaction_id ON attachments(transaction_id);
CREATE INDEX IF NOT EXISTS idx_attachments_business_id ON attachments(business_id);
CREATE INDEX IF NOT EXISTS idx_attachments_deleted_at ON attachments(deleted_at);
CREATE INDEX IF NOT EXISTS idx_assets_business_id ON assets(business_id);
CREATE INDEX IF NOT EXISTS idx_assets_deleted_at ON assets(deleted_at);

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.

DROP TABLE IF EXISTS assets;
DROP TABLE IF EXISTS attachments;
DROP TABLE IF EXISTS transfers;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS wallets;
DROP TABLE IF EXISTS businesses;
DROP TABLE IF EXISTS users;
DROP FUNCTION IF EXISTS gen_random_uuid_v7();
