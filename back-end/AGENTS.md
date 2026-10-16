# Back-End Agent Guidelines — Pun Account (ปั้น)

This directory contains the Go backend microservice and database migrations for the Pun Account system.

---

## 🚀 Quick Reference

- **Module**: `pun-account-backend` (Go 1.22+ / 1.27)
- **Framework**: [Fiber](https://gofiber.io/)
- **ORM**: [GORM](https://gorm.io/)
- **Migration Tool**: [Goose](https://github.com/pressly/goose)
- **Primary Key Specification**: UUIDv7 (RFC 9562) monotonically ordered (`github.com/google/uuid`)

---

## 🛠 Commands

```bash
# Run migrations up
make migrate-up

# Check migration status
make migrate-status

# Create new migration
make migrate-create name=migration_name

# Rollback last migration
make migrate-down

# Run unit and integration tests
go test -v ./...
```

---

## 📌 Critical Constraints

1. **UUIDv7 Primary Keys**: All tables must use UUIDv7. In SQL migrations, use `DEFAULT gen_random_uuid_v7()`. In Go structs, use `type:uuid;primaryKey;default:gen_random_uuid_v7()`.
2. **Ledger Integrity**: `wallets.balance` is a cached field. Updates must be executed inside database transactions (`tx.Begin()`) with lock clauses.
3. **No Direct Production Schema Mutations**: All table definitions and alter operations must be scripted in `db/migrations/` using Goose SQL syntax.
4. **Refer to Shared Rules**: For full coding guidelines, see [.agents/rules/golang.md](file:///../.agents/rules/golang.md).
