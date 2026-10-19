-- +goose Up
-- SQL in this section is executed when the migration is applied.

-- 1. Create service_categories table (Tracks / Verticals เช่น AI, Video & Content, Developer, Design)
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
    icon_provider VARCHAR(50) NOT NULL DEFAULT 'simple-icons', -- 'simple-icons' or 'lucide'
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

-- 3. Seed Default Tracks / Verticals
INSERT INTO service_categories (id, business_id, key, name, description, icon, color, is_system, is_active)
VALUES
    ('01927600-0001-7000-8000-000000000001', NULL, 'ai', 'AI', 'เครื่องมือปัญญาประดิษฐ์ โมเดลภาษา และ AI Generative Tools', 'sparkles', '#8B5CF6', TRUE, TRUE),
    ('01927600-0002-7000-8000-000000000002', NULL, 'video_content', 'Video & Content', 'เครื่องมือสร้าง ตัดต่อ และผลิตวิดีโอสำหรับ Content Creator', 'video', '#EF4444', TRUE, TRUE),
    ('01927600-0003-7000-8000-000000000003', NULL, 'music_sound', 'Music & Sound', 'ดนตรี ซาวด์เอฟเฟกต์ และสตรีมมิ่งเพลงลิขสิทธิ์', 'music', '#EC4899', TRUE, TRUE),
    ('01927600-0004-7000-8000-000000000004', NULL, 'design', 'Design', 'เครื่องมือออกแบบ UI/UX กราฟิก และ Creative Assets', 'palette', '#A855F7', TRUE, TRUE),
    ('01927600-0005-7000-8000-000000000005', NULL, 'storage_backup', 'Storage & Backup', 'คลาวด์สตอเรจ เก็บไฟล์ สำรองข้อมูลฟุตเทจและโปรเจกต์', 'hard-drive', '#0EA5E9', TRUE, TRUE),
    ('01927600-0006-7000-8000-000000000006', NULL, 'developer', 'Developer', 'บริการคลาวด์ โฮสติ้ง ฐานข้อมูล และเครื่องมือสำหรับนักพัฒนา', 'code', '#10B981', TRUE, TRUE),
    ('01927600-0007-7000-8000-000000000007', NULL, 'shopping', 'Shopping', 'ช่องทางสั่งซื้อสินค้า อุปกรณ์ e-Commerce และร้านค้า', 'shopping-bag', '#F59E0B', TRUE, TRUE),
    ('01927600-0008-7000-8000-000000000008', NULL, 'social_creator', 'Social & Creator', 'แพลตฟอร์มโซเชียลมีเดีย สตรีมเมอร์ และ Creator Monetization', 'share-2', '#06B6D4', TRUE, TRUE),
    ('01927600-0009-7000-8000-000000000009', NULL, 'learning', 'Learning', 'คอร์สเรียนออนไลน์ พัฒนาทักษะ และหนังสือดิจิทัล', 'graduation-cap', '#3B82F6', TRUE, TRUE)
ON CONFLICT (id) DO UPDATE SET
    key = EXCLUDED.key,
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    icon = EXCLUDED.icon,
    color = EXCLUDED.color,
    is_system = EXCLUDED.is_system,
    is_active = EXCLUDED.is_active;

-- 4. Seed Default Services associated with each track (using Simple Icons slugs where available)
INSERT INTO services (id, business_id, service_category_id, name, provider, account_number, icon, icon_provider, color, image_url, badge, is_quick, is_system, is_active)
VALUES
    -- 1. AI Track Services
    ('01927600-0105-7000-8000-000000000001', NULL, '01927600-0001-7000-8000-000000000001', 'ChatGPT', 'OpenAI', 'Chase 2983', 'openai', 'simple-icons', '#10B981', 'https://avatars.githubusercontent.com/u/14957082?s=200&v=4', 'Monthly', TRUE, TRUE, TRUE),
    ('01927600-0100-7000-8000-000000000002', NULL, '01927600-0001-7000-8000-000000000001', 'Claude', 'Anthropic', 'Chase 2983', 'claude', 'simple-icons', '#D97706', NULL, 'Monthly', TRUE, TRUE, TRUE),
    ('01927600-0100-7000-8000-000000000003', NULL, '01927600-0001-7000-8000-000000000001', 'Gemini', 'Google', 'Mastercard 9283', 'googlegemini', 'simple-icons', '#2563EB', NULL, 'Monthly', TRUE, TRUE, TRUE),
    ('01927600-0104-7000-8000-000000000004', NULL, '01927600-0001-7000-8000-000000000001', 'Midjourney', 'Midjourney', 'Chase 2983', 'sparkles', 'lucide', '#18181B', 'https://avatars.githubusercontent.com/u/1342004?s=200&v=4', 'Monthly', TRUE, TRUE, TRUE),
    ('01927600-0100-7000-8000-000000000005', NULL, '01927600-0001-7000-8000-000000000001', 'Leonardo AI', 'Leonardo', 'Chase 2983', 'sparkles', 'lucide', '#EC4899', NULL, 'Monthly', FALSE, TRUE, TRUE),
    ('01927600-0100-7000-8000-000000000006', NULL, '01927600-0001-7000-8000-000000000001', 'Runway', 'Runway', 'Chase 2983', 'video', 'lucide', '#6366F1', NULL, 'Monthly', FALSE, TRUE, TRUE),
    ('01927600-0100-7000-8000-000000000007', NULL, '01927600-0001-7000-8000-000000000001', 'Kling AI', 'Kuaishou', 'Chase 2983', 'video', 'lucide', '#F59E0B', NULL, 'Monthly', FALSE, TRUE, TRUE),
    ('01927600-0100-7000-8000-000000000008', NULL, '01927600-0001-7000-8000-000000000001', 'ElevenLabs', 'ElevenLabs', 'Chase 2983', 'elevenlabs', 'simple-icons', '#000000', NULL, 'Monthly', FALSE, TRUE, TRUE),
    ('01927600-0100-7000-8000-000000000009', NULL, '01927600-0001-7000-8000-000000000001', 'Perplexity', 'Perplexity AI', 'Chase 2983', 'perplexity', 'simple-icons', '#0EA5E9', NULL, 'Monthly', FALSE, TRUE, TRUE),
    ('01927600-0100-7000-8000-000000000010', NULL, '01927600-0001-7000-8000-000000000001', 'Canva AI', 'Canva', 'KBank 1234', 'palette', 'lucide', '#00C4CC', NULL, 'Monthly', FALSE, TRUE, TRUE),

    -- 2. Video & Content Track Services
    ('01927600-0107-7000-8000-000000000001', NULL, '01927600-0002-7000-8000-000000000002', 'YouTube Premium', 'Google', 'Mastercard 9283', 'youtube', 'simple-icons', '#FF0000', NULL, 'Monthly', TRUE, TRUE, TRUE),
    ('01927600-0200-7000-8000-000000000002', NULL, '01927600-0002-7000-8000-000000000002', 'YouTube Studio', 'Google', 'Mastercard 9283', 'youtube', 'simple-icons', '#DC2626', NULL, 'Active', FALSE, TRUE, TRUE),
    ('01927600-0103-7000-8000-000000000003', NULL, '01927600-0002-7000-8000-000000000002', 'CapCut', 'ByteDance', 'Chase 2983', 'video', 'lucide', '#111827', 'https://avatars.githubusercontent.com/u/5155369?s=200&v=4', 'Monthly', TRUE, TRUE, TRUE),
    ('01927600-0200-7000-8000-000000000004', NULL, '01927600-0002-7000-8000-000000000002', 'Adobe Premiere Pro', 'Adobe', 'Mastercard 9283', 'video', 'lucide', '#9999FF', NULL, 'Monthly', TRUE, TRUE, TRUE),
    ('01927600-0200-7000-8000-000000000005', NULL, '01927600-0002-7000-8000-000000000002', 'Adobe After Effects', 'Adobe', 'Mastercard 9283', 'video', 'lucide', '#9999FF', NULL, 'Monthly', FALSE, TRUE, TRUE),
    ('01927600-0200-7000-8000-000000000006', NULL, '01927600-0002-7000-8000-000000000002', 'DaVinci Resolve Studio', 'Blackmagic Design', 'KBank 1234', 'davinciresolve', 'simple-icons', '#F97316', NULL, 'One-Time', FALSE, TRUE, TRUE),
    ('01927600-0200-7000-8000-000000000007', NULL, '01927600-0002-7000-8000-000000000002', 'Final Cut Pro', 'Apple', 'Chase 2983', 'apple', 'simple-icons', '#3B82F6', NULL, 'One-Time', FALSE, TRUE, TRUE),
    ('01927600-0101-7000-8000-000000000001', NULL, '01927600-0002-7000-8000-000000000002', 'Canva', 'Canva', 'KBank 1234', 'palette', 'lucide', '#00C4CC', 'https://avatars.githubusercontent.com/u/10639145?s=200&v=4', 'Annual', TRUE, TRUE, TRUE),
    ('01927600-0200-7000-8000-000000000009', NULL, '01927600-0002-7000-8000-000000000002', 'Envato Elements', 'Envato', 'KBank 1234', 'envato', 'simple-icons', '#82B541', NULL, 'Annual', FALSE, TRUE, TRUE),
    ('01927600-0200-7000-8000-000000000010', NULL, '01927600-0002-7000-8000-000000000002', 'Storyblocks', 'Storyblocks', 'Chase 2983', 'video', 'lucide', '#3B82F6', NULL, 'Annual', FALSE, TRUE, TRUE),
    ('01927600-0200-7000-8000-000000000011', NULL, '01927600-0002-7000-8000-000000000002', 'Artlist', 'Artlist', 'KBank 1234', 'music', 'lucide', '#F59E0B', NULL, 'Annual', FALSE, TRUE, TRUE),
    ('01927600-0106-7000-8000-000000000001', NULL, '01927600-0002-7000-8000-000000000002', 'Epidemic Sound', 'Epidemic Sound', 'KBank 1234', 'music', 'lucide', '#1DB954', 'https://avatars.githubusercontent.com/u/9919?s=200&v=4', 'Monthly', FALSE, TRUE, TRUE),
    ('01927600-0200-7000-8000-000000000013', NULL, '01927600-0002-7000-8000-000000000002', 'Motion Array', 'Motion Array', 'Chase 2983', 'video', 'lucide', '#E11D48', NULL, 'Annual', FALSE, TRUE, TRUE),

    -- 3. Music & Sound Track Services
    ('01927600-0300-7000-8000-000000000001', NULL, '01927600-0003-7000-8000-000000000003', 'Spotify', 'Spotify', 'KBank 1234', 'spotify', 'simple-icons', '#1DB954', NULL, 'Monthly', TRUE, TRUE, TRUE),
    ('01927600-0300-7000-8000-000000000002', NULL, '01927600-0003-7000-8000-000000000003', 'Apple Music', 'Apple', 'Chase 2983', 'applemusic', 'simple-icons', '#FA243C', NULL, 'Monthly', TRUE, TRUE, TRUE),
    ('01927600-0300-7000-8000-000000000003', NULL, '01927600-0003-7000-8000-000000000003', 'YouTube Music', 'Google', 'Mastercard 9283', 'youtubemusic', 'simple-icons', '#FF0000', NULL, 'Monthly', FALSE, TRUE, TRUE),
    ('01927600-0300-7000-8000-000000000004', NULL, '01927600-0003-7000-8000-000000000003', 'Epidemic Sound Music', 'Epidemic Sound', 'KBank 1234', 'music', 'lucide', '#1DB954', NULL, 'Monthly', FALSE, TRUE, TRUE),
    ('01927600-0300-7000-8000-000000000005', NULL, '01927600-0003-7000-8000-000000000003', 'Artlist Music', 'Artlist', 'KBank 1234', 'music', 'lucide', '#F59E0B', NULL, 'Annual', FALSE, TRUE, TRUE),
    ('01927600-0300-7000-8000-000000000006', NULL, '01927600-0003-7000-8000-000000000003', 'Soundstripe', 'Soundstripe', 'Chase 2983', 'music', 'lucide', '#3B82F6', NULL, 'Annual', FALSE, TRUE, TRUE),

    -- 4. Design Track Services
    ('01927600-0301-7000-8000-000000000001', NULL, '01927600-0004-7000-8000-000000000004', 'Figma', 'Figma', 'KBank 1234', 'figma', 'simple-icons', '#A855F7', 'https://avatars.githubusercontent.com/u/5155369?s=200&v=4', 'Monthly', TRUE, TRUE, TRUE),
    ('01927600-0102-7000-8000-000000000002', NULL, '01927600-0004-7000-8000-000000000004', 'Adobe Creative Cloud', 'Adobe', 'Mastercard 9283', 'palette', 'lucide', '#ED2224', 'https://avatars.githubusercontent.com/u/2232217?s=200&v=4', 'Monthly', TRUE, TRUE, TRUE),
    ('01927600-0400-7000-8000-000000000003', NULL, '01927600-0004-7000-8000-000000000004', 'Canva Design', 'Canva', 'KBank 1234', 'palette', 'lucide', '#00C4CC', NULL, 'Annual', FALSE, TRUE, TRUE),
    ('01927600-0400-7000-8000-000000000004', NULL, '01927600-0004-7000-8000-000000000004', 'Framer', 'Framer', 'Chase 2983', 'framer', 'simple-icons', '#0055FF', NULL, 'Monthly', FALSE, TRUE, TRUE),
    ('01927600-0400-7000-8000-000000000005', NULL, '01927600-0004-7000-8000-000000000004', 'Freepik', 'Freepik', 'KBank 1234', 'freepik', 'simple-icons', '#1E40AF', NULL, 'Annual', FALSE, TRUE, TRUE),
    ('01927600-0400-7000-8000-000000000006', NULL, '01927600-0004-7000-8000-000000000004', 'Icons8', 'Icons8', 'Chase 2983', 'icons8', 'simple-icons', '#10B981', NULL, 'Annual', FALSE, TRUE, TRUE),
    ('01927600-0400-7000-8000-000000000007', NULL, '01927600-0004-7000-8000-000000000004', 'Envato Elements Design', 'Envato', 'KBank 1234', 'envato', 'simple-icons', '#82B541', NULL, 'Annual', FALSE, TRUE, TRUE),

    -- 5. Storage & Backup Track Services
    ('01927600-0500-7000-8000-000000000001', NULL, '01927600-0005-7000-8000-000000000005', 'Google Drive', 'Google', 'Mastercard 9283', 'googledrive', 'simple-icons', '#34A853', NULL, 'Monthly', TRUE, TRUE, TRUE),
    ('01927600-0500-7000-8000-000000000002', NULL, '01927600-0005-7000-8000-000000000005', 'Google One', 'Google', 'Mastercard 9283', 'google', 'simple-icons', '#4285F4', NULL, 'Monthly', FALSE, TRUE, TRUE),
    ('01927600-0500-7000-8000-000000000003', NULL, '01927600-0005-7000-8000-000000000005', 'Dropbox', 'Dropbox', 'Chase 2983', 'dropbox', 'simple-icons', '#0061FF', NULL, 'Monthly', TRUE, TRUE, TRUE),
    ('01927600-0500-7000-8000-000000000004', NULL, '01927600-0005-7000-8000-000000000005', 'OneDrive', 'Microsoft', 'Mastercard 9283', 'cloud', 'lucide', '#0078D4', NULL, 'Monthly', FALSE, TRUE, TRUE),
    ('01927600-0500-7000-8000-000000000005', NULL, '01927600-0005-7000-8000-000000000005', 'iCloud+', 'Apple', 'Chase 2983', 'icloud', 'simple-icons', '#38BDF8', NULL, 'Monthly', TRUE, TRUE, TRUE),
    ('01927600-0500-7000-8000-000000000006', NULL, '01927600-0005-7000-8000-000000000005', 'Backblaze', 'Backblaze', 'Chase 2983', 'backblaze', 'simple-icons', '#DC2626', NULL, 'Monthly', FALSE, TRUE, TRUE),
    ('01927600-0500-7000-8000-000000000007', NULL, '01927600-0005-7000-8000-000000000005', 'Cloudflare R2', 'Cloudflare', 'Chase 2983', 'cloudflare', 'simple-icons', '#F48120', NULL, 'Usage', FALSE, TRUE, TRUE),
    ('01927600-0500-7000-8000-000000000008', NULL, '01927600-0005-7000-8000-000000000005', 'AWS S3', 'Amazon Web Services', 'Mastercard 9283', 'cloud', 'lucide', '#EAB308', NULL, 'Usage', FALSE, TRUE, TRUE),

    -- 6. Developer Track Services
    ('01927600-0600-7000-8000-000000000001', NULL, '01927600-0006-7000-8000-000000000006', 'Neon', 'Neon', 'Chase 2983', 'neon', 'simple-icons', '#00E599', NULL, 'Monthly', FALSE, TRUE, TRUE),
    ('01927600-0600-7000-8000-000000000002', NULL, '01927600-0006-7000-8000-000000000006', 'Hostinger — Domain', 'Hostinger', 'KBank 1234', 'hostinger', 'simple-icons', '#673AB7', NULL, 'Annual', FALSE, TRUE, TRUE),
    ('01927600-0600-7000-8000-000000000003', NULL, '01927600-0006-7000-8000-000000000006', 'Hostinger — Hosting', 'Hostinger', 'KBank 1234', 'hostinger', 'simple-icons', '#673AB7', NULL, 'Annual', FALSE, TRUE, TRUE),
    ('01927600-0202-7000-8000-000000000001', NULL, '01927600-0006-7000-8000-000000000006', 'GitHub', 'GitHub', 'Chase 2983', 'github', 'simple-icons', '#6366F1', 'https://avatars.githubusercontent.com/u/9919?s=200&v=4', 'Monthly', TRUE, TRUE, TRUE),
    ('01927600-0600-7000-8000-000000000005', NULL, '01927600-0006-7000-8000-000000000006', 'GitLab', 'GitLab', 'Chase 2983', 'gitlab', 'simple-icons', '#FC6D26', NULL, 'Monthly', FALSE, TRUE, TRUE),
    ('01927600-0204-7000-8000-000000000001', NULL, '01927600-0006-7000-8000-000000000006', 'Vercel', 'Vercel', 'Chase 2983', 'vercel', 'simple-icons', '#000000', 'https://avatars.githubusercontent.com/u/14985020?s=200&v=4', 'Monthly', TRUE, TRUE, TRUE),
    ('01927600-0600-7000-8000-000000000007', NULL, '01927600-0006-7000-8000-000000000006', 'Cloudflare', 'Cloudflare', 'Chase 2983', 'cloudflare', 'simple-icons', '#F48120', NULL, 'Monthly', FALSE, TRUE, TRUE),
    ('01927600-0600-7000-8000-000000000008', NULL, '01927600-0006-7000-8000-000000000006', 'Railway', 'Railway', 'Chase 2983', 'railway', 'simple-icons', '#0B0D0E', NULL, 'Usage', FALSE, TRUE, TRUE),
    ('01927600-0600-7000-8000-000000000009', NULL, '01927600-0006-7000-8000-000000000006', 'Render', 'Render', 'Chase 2983', 'render', 'simple-icons', '#46E3B7', NULL, 'Usage', FALSE, TRUE, TRUE),
    ('01927600-0203-7000-8000-000000000001', NULL, '01927600-0006-7000-8000-000000000006', 'Supabase', 'Supabase', 'KBank 1234', 'supabase', 'simple-icons', '#3ECF8E', 'https://avatars.githubusercontent.com/u/54469796?s=200&v=4', 'Monthly', TRUE, TRUE, TRUE),
    ('01927600-0600-7000-8000-000000000011', NULL, '01927600-0006-7000-8000-000000000006', 'Firebase', 'Google', 'Mastercard 9283', 'firebase', 'simple-icons', '#FFA611', NULL, 'Usage', FALSE, TRUE, TRUE),
    ('01927600-0600-7000-8000-000000000012', NULL, '01927600-0006-7000-8000-000000000006', 'Sentry', 'Sentry', 'Chase 2983', 'sentry', 'simple-icons', '#362D59', NULL, 'Monthly', FALSE, TRUE, TRUE),
    ('01927600-0600-7000-8000-000000000013', NULL, '01927600-0006-7000-8000-000000000006', 'Docker / Docker Hub', 'Docker', 'Chase 2983', 'docker', 'simple-icons', '#2496ED', NULL, 'Monthly', FALSE, TRUE, TRUE),
    ('01927600-0600-7000-8000-000000000014', NULL, '01927600-0006-7000-8000-000000000006', 'npm / GitHub Packages', 'GitHub', 'Chase 2983', 'npm', 'simple-icons', '#CB3837', NULL, 'Monthly', FALSE, TRUE, TRUE),
    ('01927600-0600-7000-8000-000000000015', NULL, '01927600-0006-7000-8000-000000000006', 'DigitalOcean', 'DigitalOcean', 'Mastercard 9283', 'digitalocean', 'simple-icons', '#0080FF', NULL, 'Monthly', FALSE, TRUE, TRUE),
    ('01927600-0201-7000-8000-000000000001', NULL, '01927600-0006-7000-8000-000000000006', 'AWS', 'Amazon Web Services', 'Mastercard 9283', 'cloud', 'lucide', '#F59E0B', 'https://avatars.githubusercontent.com/u/2232217?s=200&v=4', 'Usage', TRUE, TRUE, TRUE),
    ('01927600-0600-7000-8000-000000000017', NULL, '01927600-0006-7000-8000-000000000006', 'Google Cloud', 'Google', 'Mastercard 9283', 'googlecloud', 'simple-icons', '#4285F4', NULL, 'Usage', FALSE, TRUE, TRUE),

    -- 7. Shopping Track Services
    ('01927600-0700-7000-8000-000000000001', NULL, '01927600-0007-7000-8000-000000000007', 'Shopee', 'Shopee', 'KBank 1234', 'shopee', 'simple-icons', '#EE4D2D', NULL, 'Active', TRUE, TRUE, TRUE),
    ('01927600-0700-7000-8000-000000000002', NULL, '01927600-0007-7000-8000-000000000007', 'Lazada', 'Lazada', 'Mastercard 9283', 'shopping-bag', 'lucide', '#0F146D', NULL, 'Active', TRUE, TRUE, TRUE),
    ('01927600-0700-7000-8000-000000000003', NULL, '01927600-0007-7000-8000-000000000007', 'TikTok Shop', 'ByteDance', 'KBank 1234', 'tiktok', 'simple-icons', '#000000', NULL, 'Active', TRUE, TRUE, TRUE),
    ('01927600-0700-7000-8000-000000000004', NULL, '01927600-0007-7000-8000-000000000007', 'Amazon', 'Amazon', 'Chase 2983', 'shopping-bag', 'lucide', '#FF9900', NULL, 'Active', FALSE, TRUE, TRUE),
    ('01927600-0700-7000-8000-000000000005', NULL, '01927600-0007-7000-8000-000000000007', 'ร้านค้า / Store', 'Store', 'KBank 1234', 'shopping-bag', 'lucide', '#64748B', NULL, 'Active', FALSE, TRUE, TRUE),
    ('01927600-0700-7000-8000-000000000006', NULL, '01927600-0007-7000-8000-000000000007', 'Apple Store', 'Apple', 'Chase 2983', 'apple', 'simple-icons', '#000000', NULL, 'Active', TRUE, TRUE, TRUE),
    ('01927600-0700-7000-8000-000000000007', NULL, '01927600-0007-7000-8000-000000000007', 'Google Play', 'Google', 'Mastercard 9283', 'googleplay', 'simple-icons', '#01875F', NULL, 'Active', FALSE, TRUE, TRUE),

    -- 8. Social & Creator Track Services
    ('01927600-0800-7000-8000-000000000001', NULL, '01927600-0008-7000-8000-000000000008', 'TikTok', 'ByteDance', 'Chase 2983', 'tiktok', 'simple-icons', '#000000', NULL, 'Active', TRUE, TRUE, TRUE),
    ('01927600-0800-7000-8000-000000000002', NULL, '01927600-0008-7000-8000-000000000008', 'Instagram', 'Meta', 'Chase 2983', 'instagram', 'simple-icons', '#E1306C', NULL, 'Active', TRUE, TRUE, TRUE),
    ('01927600-0800-7000-8000-000000000003', NULL, '01927600-0008-7000-8000-000000000008', 'Facebook', 'Meta', 'Mastercard 9283', 'facebook', 'simple-icons', '#1877F2', NULL, 'Active', TRUE, TRUE, TRUE),
    ('01927600-0800-7000-8000-000000000004', NULL, '01927600-0008-7000-8000-000000000008', 'X', 'X Corp', 'Chase 2983', 'x', 'simple-icons', '#000000', NULL, 'Active', FALSE, TRUE, TRUE),
    ('01927600-0800-7000-8000-000000000005', NULL, '01927600-0008-7000-8000-000000000008', 'YouTube', 'Google', 'Mastercard 9283', 'youtube', 'simple-icons', '#FF0000', NULL, 'Active', TRUE, TRUE, TRUE),
    ('01927600-0800-7000-8000-000000000006', NULL, '01927600-0008-7000-8000-000000000008', 'Patreon', 'Patreon', 'Chase 2983', 'patreon', 'simple-icons', '#FF424D', NULL, 'Monthly', FALSE, TRUE, TRUE),
    ('01927600-0800-7000-8000-000000000007', NULL, '01927600-0008-7000-8000-000000000008', 'Ko-fi', 'Ko-fi', 'Chase 2983', 'kofi', 'simple-icons', '#FF5E5B', NULL, 'Active', FALSE, TRUE, TRUE),
    ('01927600-0800-7000-8000-000000000008', NULL, '01927600-0008-7000-8000-000000000008', 'Gumroad', 'Gumroad', 'Chase 2983', 'gumroad', 'simple-icons', '#FF90E8', NULL, 'Active', FALSE, TRUE, TRUE),
    ('01927600-0800-7000-8000-000000000009', NULL, '01927600-0008-7000-8000-000000000008', 'Linktree', 'Linktree', 'Chase 2983', 'linktree', 'simple-icons', '#43E660', NULL, 'Monthly', FALSE, TRUE, TRUE),
    ('01927600-0800-7000-8000-000000000010', NULL, '01927600-0008-7000-8000-000000000008', 'Beacons', 'Beacons', 'Chase 2983', 'share-2', 'lucide', '#6366F1', NULL, 'Monthly', FALSE, TRUE, TRUE),

    -- 9. Learning Track Services
    ('01927600-0900-7000-8000-000000000001', NULL, '01927600-0009-7000-8000-000000000009', 'Udemy', 'Udemy', 'Chase 2983', 'udemy', 'simple-icons', '#A435F0', NULL, 'Active', TRUE, TRUE, TRUE),
    ('01927600-0900-7000-8000-000000000002', NULL, '01927600-0009-7000-8000-000000000009', 'Coursera', 'Coursera', 'Mastercard 9283', 'coursera', 'simple-icons', '#0056D2', NULL, 'Monthly', TRUE, TRUE, TRUE),
    ('01927600-0900-7000-8000-000000000003', NULL, '01927600-0009-7000-8000-000000000009', 'Skillshare', 'Skillshare', 'Chase 2983', 'skillshare', 'simple-icons', '#00FF84', NULL, 'Annual', FALSE, TRUE, TRUE),
    ('01927600-0900-7000-8000-000000000004', NULL, '01927600-0009-7000-8000-000000000009', 'Domestika', 'Domestika', 'Chase 2983', 'palette', 'lucide', '#292929', NULL, 'Active', FALSE, TRUE, TRUE),
    ('01927600-0900-7000-8000-000000000005', NULL, '01927600-0009-7000-8000-000000000009', 'LinkedIn Learning', 'LinkedIn', 'Mastercard 9283', 'graduation-cap', 'lucide', '#0A66C2', NULL, 'Monthly', FALSE, TRUE, TRUE),
    ('01927600-0900-7000-8000-000000000006', NULL, '01927600-0009-7000-8000-000000000009', 'Pluralsight', 'Pluralsight', 'Mastercard 9283', 'pluralsight', 'simple-icons', '#F15B2A', NULL, 'Monthly', FALSE, TRUE, TRUE),
    ('01927600-0900-7000-8000-000000000007', NULL, '01927600-0009-7000-8000-000000000009', 'O''Reilly', 'O''Reilly', 'Chase 2983', 'oreilly', 'simple-icons', '#D31145', NULL, 'Annual', FALSE, TRUE, TRUE)
ON CONFLICT (id) DO UPDATE SET
    service_category_id = EXCLUDED.service_category_id,
    name = EXCLUDED.name,
    provider = EXCLUDED.provider,
    account_number = EXCLUDED.account_number,
    icon = EXCLUDED.icon,
    icon_provider = EXCLUDED.icon_provider,
    color = EXCLUDED.color,
    image_url = EXCLUDED.image_url,
    badge = EXCLUDED.badge,
    is_quick = EXCLUDED.is_quick,
    is_system = EXCLUDED.is_system,
    is_active = EXCLUDED.is_active;

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.

DROP TABLE IF EXISTS services;
DROP TABLE IF EXISTS service_categories;
