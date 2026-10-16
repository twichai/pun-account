# Golang & Database Backend Development Rules

This document outlines the coding standards, database patterns, and architectural rules for the Go backend (`pun-account-backend`) in **Pun Account**.

---

## 🏛 Backend Architecture & Project Layout

The backend follows the Standard Go Project Layout under `back-end/`:

```text
back-end/
├── cmd/
│   └── api/                 # Application main entry point (main.go)
├── internal/                # Private application logic (cannot be imported outside)
│   ├── handlers/            # Fiber HTTP handlers, request parsing & validation
│   ├── services/            # Core business logic & financial ledger workflows
│   ├── repository/          # GORM database queries & transactions
│   └── models/              # GORM database models & entity structs
├── db/
│   └── migrations/          # Goose SQL migration files (00001_..., 00002_...)
├── go.mod                   # Module: pun-account-backend
├── Makefile                 # Migration & automation targets
└── .env                     # Local environment configuration
```

---

## 🔑 Database & Financial Data Model Rules

1. **UUIDv7 for All Primary Keys**:
   - Every database table MUST use **UUIDv7 (RFC 9562)** as its primary key.
   - SQL definition: `id UUID PRIMARY KEY DEFAULT gen_random_uuid_v7()`
   - Go model tag: `ID uuid.UUID gorm:"type:uuid;primaryKey;default:gen_random_uuid_v7()" json:"id"`
   - Always instantiate new IDs in Go using `uuid.NewV7()`.
   - **Reason**: 48-bit millisecond timestamp ensures monotonic sequential IDs, eliminating B-Tree index fragmentation.

2. **Ledger Integrity & Cached Balance**:
   - `wallets.balance` is a **cached snapshot** for read performance.
   - The absolute source of truth is the immutable history of `transactions` and `transfers`.
   - Balance adjustments MUST execute within an ACID database transaction (`tx := db.Begin()`) with row-level locking (`Clauses(clause.Locking{Strength: "UPDATE"})`) to avoid race conditions.

3. **Currency & Precision**:
   - In PostgreSQL, store monetary amounts as `NUMERIC(15, 2)`.
   - Avoid IEEE 754 floating-point inaccuracies in financial calculations.

4. **Database Migrations (Goose)**:
   - NEVER alter database schemas manually or rely on `AutoMigrate` for production tables.
   - Always create migrations through Goose:
     ```bash
     make migrate-create name=add_feature_table
     ```
   - Migrations must support both `-- +goose Up` and `-- +goose Down`.

---

## 💻 Go Coding Standards

1. **Fiber HTTP Best Practices**:
   - Use Fiber's context methods (`c.BodyParser(&req)`, `c.Status(fiber.StatusOK).JSON(...)`).
   - Validate incoming requests strictly (validate payload structure, required fields, and UUID formatting).
   - Return standardized JSON error responses:
     ```json
     {
       "error": {
         "code": "INVALID_INPUT",
         "message": "The transaction amount must be greater than zero"
       }
     }
     ```

2. **Error Handling**:
   - Never ignore errors with `_ = fn()`.
   - Wrap errors with descriptive context:
     ```go
     if err != nil {
         return fmt.Errorf("failed to process transfer for wallet %s: %w", walletID, err)
     }
     ```
   - Log errors at the handler boundary with appropriate log levels.

3. **Context & Concurrency**:
   - Pass `ctx context.Context` into database queries and service calls.
   - Ensure goroutines terminate predictably and do not leak resources.

4. **Code Quality Commands**:
   ```bash
   cd back-end
   go vet ./...
   go test -race ./...
   ```
