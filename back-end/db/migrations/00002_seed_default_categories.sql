-- +goose Up
-- SQL in this section is executed when the migration is applied.

-- Seed Default Categories (System Default: business_id = NULL, is_system = TRUE, is_active = TRUE)
INSERT INTO categories (id, business_id, name, type, icon, parent_id, is_system, is_active)
VALUES
    -- Income
    ('01927500-0001-7000-8000-000000000001', NULL, 'ขายสินค้า', 'income', 'shopping-bag', NULL, TRUE, TRUE),
    ('01927500-0002-7000-8000-000000000002', NULL, 'ค่าบริการ', 'income', 'briefcase', NULL, TRUE, TRUE),
    ('01927500-0003-7000-8000-000000000003', NULL, 'งาน Freelance', 'income', 'laptop', NULL, TRUE, TRUE),
    ('01927500-0004-7000-8000-000000000004', NULL, 'รายได้อื่น ๆ', 'income', 'plus-circle', NULL, TRUE, TRUE),

    -- Expense
    ('01927500-0005-7000-8000-000000000005', NULL, 'วัตถุดิบ', 'expense', 'package', NULL, TRUE, TRUE),
    ('01927500-0006-7000-8000-000000000006', NULL, 'สินค้า', 'expense', 'shopping-cart', NULL, TRUE, TRUE),
    ('01927500-0007-7000-8000-000000000007', NULL, 'การตลาด', 'expense', 'megaphone', NULL, TRUE, TRUE),
    ('01927500-0008-7000-8000-000000000008', NULL, 'Software', 'expense', 'monitor', NULL, TRUE, TRUE),
    ('01927500-0009-7000-8000-000000000009', NULL, 'อุปกรณ์', 'expense', 'wrench', NULL, TRUE, TRUE),
    ('01927500-0010-7000-8000-000000000010', NULL, 'ค่าเช่า', 'expense', 'building', NULL, TRUE, TRUE),
    ('01927500-0011-7000-8000-000000000011', NULL, 'อินเทอร์เน็ต', 'expense', 'wifi', NULL, TRUE, TRUE),
    ('01927500-0012-7000-8000-000000000012', NULL, 'เดินทาง', 'expense', 'car', NULL, TRUE, TRUE),
    ('01927500-0013-7000-8000-000000000013', NULL, 'ค่าขนส่ง', 'expense', 'truck', NULL, TRUE, TRUE),
    ('01927500-0014-7000-8000-000000000014', NULL, 'ค่าธรรมเนียม', 'expense', 'credit-card', NULL, TRUE, TRUE),
    ('01927500-0015-7000-8000-000000000015', NULL, 'ค่าใช้จ่ายอื่น ๆ', 'expense', 'more-horizontal', NULL, TRUE, TRUE)
ON CONFLICT (id) DO NOTHING;

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.

DELETE FROM categories WHERE is_system = TRUE AND business_id IS NULL;
