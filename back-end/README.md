# ปั้น (Pun Account) - Back-End Database & Services

โครงสร้างฐานข้อมูลและระบบ Backend สำหรับ **ปั้น (Pun Account) — แอปการเงินสำหรับ One Person Company**

## 🏗️ โครงสร้างฐานข้อมูล (Database Schema)

ออกแบบตามแนวคิด **Event-driven Financial Model สำหรับธุรกิจคนเดียว (One Person Company)** ไม่ซับซ้อนเกินไปแบบ ERP แต่ถูกต้องตามหลักการเงินตั้งแต่วันแรก:

```text
User
 └── Business
       ├── Wallet (Cash, Bank, E-Wallet, Credit Card)
       ├── Category (Expense, Income with Hierarchy)
       ├── Transaction (Income, Expense, Owner Withdrawal, Owner Contribution)
       ├── Transfer (Inter-wallet transfer: KBank -> Cash)
       ├── Attachment (Receipts / Invoices)
       └── Asset (Company equipment / CapEx)
```

### 1. `users`
เจ้าของบัญชีผู้ใช้ระบบ

### 2. `businesses`
รองรับ User 1 คน มีได้หลายธุรกิจในอนาคต (เช่น Teerasak ➔ DinoPOS, Freelance)  
*Transaction ทั้งหมดผูกกับ `business_id`*

### 3. `wallets`
กระเป๋าเงิน (Cash, KBank, SCB, Credit Card, TrueMoney)  
- `balance`: เก็บเป็น **Cached value** เพื่อ performance
- **Source of truth** ที่แท้จริงคือรายการ Transaction / Transfer

### 4. `categories`
หมวดหมู่รายรับ/รายจ่าย รองรับ hierarchy (Parent-Child)  
- มี System Default Categories (`business_id IS NULL`) พร้อมใช้ทันที
- ผู้ใช้สามารถสร้าง custom categories สำหรับธุรกิจของตัวเองได้

### 5. `transactions`
บันทึกเหตุการณ์ทางการเงินทุกครั้ง:
- `income` (รายได้)
- `expense` (ค่าใช้จ่าย)
- `owner_withdrawal` (เจ้าของถอนเงินไปใช้ส่วนตัว)
- `owner_contribution` (เจ้าของเติมเงินเข้าธุรกิจ)
- `transfer` (โอนเงิน)

### 6. `transfers`
การโยกย้ายเงินข้ามกระเป๋า (เช่น ถอนเงินจากธนาคารมาเป็นเงินสด) ไม่ใช่รายรับและไม่ใช่รายจ่าย ยอดรวมธุรกิจไม่เปลี่ยนแปลง

### 7. `attachments`
ไฟล์แนบหลักฐานการเงิน (สลิปโอนเงิน, ใบเสร็จ, ใบกำกับภาษี)

### 8. `assets`
สินทรัพย์ธุรกิจ (เช่น MacBook, กล้อง, โต๊ะทำงาน) รองรับการตอบคำถาม *"เงินหายไปไหน? -> เปลี่ยนเป็นสินทรัพย์ MacBook"* โดยยังไม่ต้องเปิด UI ในช่วงต้น

---

## 🔑 Primary Key: UUIDv7 (Sequential & Monotonic)

ระบบใช้ **UUIDv7 (RFC 9562)** เป็น Primary Key ทุกตาราง:
- **Timestamp 48-bit แรก**: สร้างตามมิลลิวินาที ทำให้ค่าเรียงลำดับตามเวลาเสมอ (Monotonic)
- **ไม่เกิด B-Tree Page Split**: Insert ต่อท้ายเหมือน `BIGSERIAL` ลด Index Bloat และ I/O
- **PostgreSQL Function**: `gen_random_uuid_v7()` ฝังไว้ใน Migration พร้อมใช้งานทันที
- **Go Support**: ติดตั้ง `github.com/google/uuid` (v1.6+) สำหรับสร้าง `uuid.NewV7()` จากฝั่ง App

---

## 🚀 Migration with Goose

เครื่องมือจัดการ Database Migration: [goose](https://github.com/pressly/goose)

### คำสั่งใช้งาน (ผ่าน Makefile)

```bash
# ตรวจสอบสถานะ migration
make migrate-status

# รัน migration ขึ้นทั้งหมด
make migrate-up

# ย้อนกลับ migration ล่าสุด 1 step
make migrate-down

# รีเซ็ต migration ทั้งหมด
make migrate-reset

# สร้าง migration file ใหม่
make migrate-create name=add_contacts_table
```

### Direct Goose CLI Commands

```bash
goose -dir db/migrations postgres "postgres://noah@localhost:5432/pun_account?sslmode=disable" status
goose -dir db/migrations postgres "postgres://noah@localhost:5432/pun_account?sslmode=disable" up
goose -dir db/migrations postgres "postgres://noah@localhost:5432/pun_account?sslmode=disable" down
```

---

## 📁 Migration Files
1. `db/migrations/00001_create_initial_schema.sql` — สร้าง Tables ทั้ง 8 ตาราง, UUIDv7 function, Foreign Keys, Soft Delete (`deleted_at`), และ Performance Indexes
2. `db/migrations/00002_seed_default_categories.sql` — Seed หมวดหมู่เริ่มต้น 15 รายการ (Income 4 รายการ, Expense 11 รายการ) พร้อม `is_system=TRUE`, `is_active=TRUE`


