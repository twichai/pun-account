-- +goose Up
-- SQL in this section is executed when the migration is applied.

-- 1. Create service_categories table (Tracks / Verticals เช่น Content Creator, Developer, Designer)
CREATE TABLE IF NOT EXISTS service_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE, -- NULL for system default tracks
    key VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    icon VARCHAR(100),
    color VARCHAR(50),
    is_system BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_service_categories_business_id ON service_categories(business_id);
CREATE INDEX IF NOT EXISTS idx_service_categories_key ON service_categories(key);
CREATE INDEX IF NOT EXISTS idx_service_categories_is_system ON service_categories(is_system);
CREATE INDEX IF NOT EXISTS idx_service_categories_deleted_at ON service_categories(deleted_at);

-- 2. Create services table (SaaS, Subscriptions, Cloud, AI tools, recurring payment recipients)
CREATE TABLE IF NOT EXISTS services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE, -- NULL for system default services
    service_category_id UUID REFERENCES service_categories(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    provider VARCHAR(100),
    account_number VARCHAR(100),
    icon VARCHAR(100),
    color VARCHAR(50),
    image_url TEXT,
    badge VARCHAR(50),
    is_quick BOOLEAN NOT NULL DEFAULT FALSE,
    is_system BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_services_business_id ON services(business_id);
CREATE INDEX IF NOT EXISTS idx_services_service_category_id ON services(service_category_id);
CREATE INDEX IF NOT EXISTS idx_services_is_quick ON services(is_quick);
CREATE INDEX IF NOT EXISTS idx_services_is_system ON services(is_system);
CREATE INDEX IF NOT EXISTS idx_services_deleted_at ON services(deleted_at);

-- 3. Seed Default Tracks with heavy focus on Content Creator
INSERT INTO service_categories (id, business_id, key, name, description, icon, color, is_system, is_active)
VALUES
    ('01927600-0001-7000-8000-000000000001', NULL, 'content_creator', 'Content Creator', 'สำหรับยูทูบเบอร์, สตรีมเมอร์, คอนเทนต์ครีเอเตอร์, วิดีโอ และ AI tools', 'video', '#EF4444', TRUE, TRUE),
    ('01927600-0002-7000-8000-000000000002', NULL, 'developer', 'Developer', 'บริการคลาวด์ ซอฟต์แวร์ API และโค้ดดิ้งสำหรับนักพัฒนา', 'code', '#10B981', TRUE, TRUE),
    ('01927600-0003-7000-8000-000000000003', NULL, 'designer', 'Designer', 'เครื่องมือออกแบบ UI/UX, กราฟิก, ฟอนต์ และ asset design', 'palette', '#A855F7', TRUE, TRUE)
ON CONFLICT (id) DO NOTHING;

-- 4. Seed Default Services associated with each track
INSERT INTO services (id, business_id, service_category_id, name, provider, account_number, icon, color, image_url, badge, is_quick, is_system, is_active)
VALUES
    -- Content Creator Track Services
    ('01927600-0101-7000-8000-000000000001', NULL, '01927600-0001-7000-8000-000000000001', 'Canva Pro', 'Canva', 'KBank 1234', 'palette', '#00C4CC', 'https://avatars.githubusercontent.com/u/10639145?s=200&v=4', 'Annual', TRUE, TRUE, TRUE),
    ('01927600-0102-7000-8000-000000000002', NULL, '01927600-0001-7000-8000-000000000001', 'Adobe Creative Cloud', 'Adobe', 'Mastercard 9283', 'palette', '#ED2224', 'https://avatars.githubusercontent.com/u/2232217?s=200&v=4', 'Monthly', TRUE, TRUE, TRUE),
    ('01927600-0103-7000-8000-000000000003', NULL, '01927600-0001-7000-8000-000000000001', 'CapCut Pro', 'ByteDance', 'Chase 2983', 'video', '#111827', 'https://avatars.githubusercontent.com/u/5155369?s=200&v=4', 'Monthly', TRUE, TRUE, TRUE),
    ('01927600-0104-7000-8000-000000000004', NULL, '01927600-0001-7000-8000-000000000001', 'Midjourney', 'Midjourney', 'Chase 2983', 'sparkles', '#18181B', 'https://avatars.githubusercontent.com/u/1342004?s=200&v=4', 'Monthly', TRUE, TRUE, TRUE),
    ('01927600-0105-7000-8000-000000000001', NULL, '01927600-0001-7000-8000-000000000001', 'OpenAI ChatGPT Plus', 'OpenAI', 'Chase 2983', 'sparkles', '#10B981', 'https://avatars.githubusercontent.com/u/14957082?s=200&v=4', 'Active', TRUE, TRUE, TRUE),
    ('01927600-0106-7000-8000-000000000001', NULL, '01927600-0001-7000-8000-000000000001', 'Epidemic Sound', 'Epidemic Sound', 'KBank 1234', 'music', '#1DB954', 'https://avatars.githubusercontent.com/u/9919?s=200&v=4', 'Active', TRUE, TRUE, TRUE),
    ('01927600-0107-7000-8000-000000000001', NULL, '01927600-0001-7000-8000-000000000001', 'YouTube Premium', 'Google', 'Mastercard 9283', 'play-circle', '#FF0000', NULL, 'Monthly', FALSE, TRUE, TRUE),
    ('01927600-0108-7000-8000-000000000001', NULL, '01927600-0001-7000-8000-000000000001', 'Notion AI', 'Notion', 'Chase 2983', 'book-open', '#09090B', NULL, 'Active', FALSE, TRUE, TRUE),

    -- Developer Track Services
    ('01927600-0201-7000-8000-000000000001', NULL, '01927600-0002-7000-8000-000000000002', 'AWS Infrastructure', 'Amazon Web Services', 'Mastercard 9283', 'cloud', '#F59E0B', 'https://avatars.githubusercontent.com/u/2232217?s=200&v=4', 'Active', TRUE, TRUE, TRUE),
    ('01927600-0202-7000-8000-000000000001', NULL, '01927600-0002-7000-8000-000000000002', 'GitHub Copilot', 'GitHub', 'Chase 2983', 'code', '#6366F1', 'https://avatars.githubusercontent.com/u/9919?s=200&v=4', 'Monthly', TRUE, TRUE, TRUE),
    ('01927600-0203-7000-8000-000000000001', NULL, '01927600-0002-7000-8000-000000000002', 'Supabase Database', 'Supabase', 'KBank 1234', 'database', '#22C55E', 'https://avatars.githubusercontent.com/u/54469796?s=200&v=4', 'Active', FALSE, TRUE, TRUE),
    ('01927600-0204-7000-8000-000000000001', NULL, '01927600-0002-7000-8000-000000000002', 'Vercel Pro', 'Vercel', 'Chase 2983', 'triangle', '#64748B', 'https://avatars.githubusercontent.com/u/14985020?s=200&v=4', 'Active', FALSE, TRUE, TRUE),
    ('01927600-0205-7000-8000-000000000001', NULL, '01927600-0002-7000-8000-000000000002', 'Apple Developer Account', 'Apple', 'Chase 2983', 'laptop', '#0EA5E9', 'https://avatars.githubusercontent.com/u/10639145?s=200&v=4', 'Annual', FALSE, TRUE, TRUE),

    -- Designer Track Services
    ('01927600-0301-7000-8000-000000000001', NULL, '01927600-0003-7000-8000-000000000003', 'Figma Enterprise', 'Figma', 'KBank 1234', 'palette', '#A855F7', 'https://avatars.githubusercontent.com/u/5155369?s=200&v=4', 'Active', TRUE, TRUE, TRUE),
    ('01927600-0302-7000-8000-000000000001', NULL, '01927600-0003-7000-8000-000000000003', 'Freepik & Envato Elements', 'Envato', 'KBank 1234', 'layers', '#F97316', NULL, 'Annual', FALSE, TRUE, TRUE)
ON CONFLICT (id) DO NOTHING;

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.

DROP TABLE IF EXISTS services;
DROP TABLE IF EXISTS service_categories;
