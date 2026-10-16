# AGENTS.md — Pun Account (ปั้น)

Welcome to **Pun Account (ปั้น)** — a tailored financial application designed for One Person Companies (solopreneurs, freelancers, and indie makers).

This project is structured as a monorepo containing:
- **Frontend (Root)**: Flutter cross-platform client with `shadcn_flutter` UI design system.
- **Backend (`back-end/`)**: Go (Golang) microservices with Fiber, GORM, PostgreSQL, and Goose migrations.

---

## 🏛 Repository Architecture

```text
pun_account/
├── lib/                     # Flutter application code
│   └── main.dart            # Flutter entry point
├── test/                    # Flutter unit & widget tests
├── pubspec.yaml             # Flutter dependencies (shadcn_flutter, etc.)
├── Makefile                 # Workspace automation & migration proxies
├── .agents/
│   ├── rules/
│   │   ├── flutter.md       # Flutter & shadcn_flutter rules and guidelines
│   │   └── golang.md        # Go backend & database design rules
│   └── skills/              # Installed agent skills (e.g., shadcn-flutter)
└── back-end/                # Go backend service
    ├── cmd/                 # Application entrypoints (e.g., api server)
    ├── internal/            # Private application packages
    │   └── models/          # GORM models & domain entities
    ├── db/
    │   └── migrations/      # Goose SQL migration files
    ├── go.mod               # Go module: pun-account-backend
    └── Makefile             # Goose migration commands
```

---

## ⚡ Core Principles & Financial Architecture

1. **One Person Company Focus**:
   - Designed for solopreneurs managing mixed personal/business finances without enterprise ERP complexity.
   - Core entities: `User` -> `Business` -> `Wallet`, `Category`, `Transaction`, `Transfer`, `Attachment`, `Asset`.
2. **Sequential UUIDv7 as Primary Keys**:
   - All database tables use **UUIDv7** (RFC 9562) with 48-bit millisecond timestamps for monotonically increasing IDs.
   - Prevents B-Tree index fragmentation and maintains optimal I/O throughput.
3. **Ledger as Source of Truth**:
   - `Wallet.balance` is stored as a **cached snapshot** for performance.
   - The absolute source of truth is the immutable audit trail of `transactions` and `transfers`.
4. **Clean Code & Quality**:
   - Always run static analysis before completing tasks:
     - Flutter: `flutter analyze`
     - Backend: `golangci-lint run` or `go vet ./...`

---

## 🛠 Common Commands

### Root Workspace & Migrations
```bash
# Run database migrations up
make migrate-up

# Check migration status
make migrate-status

# Create a new SQL migration
make migrate-create name=add_accounts_table

# Rollback last migration
make migrate-down
```

### Flutter Frontend
```bash
# Analyze code
flutter analyze

# Run unit & widget tests
flutter test

# Add new dependency
flutter pub add <package>
```

### Go Backend (`back-end/`)
```bash
# Run tests
cd back-end && go test ./...

# Tidy dependencies
cd back-end && go mod tidy
```

---

## 📖 Detailed Rules

When working in specific areas of the codebase, refer to the dedicated rules:
- **Flutter UI & Dart**: [.agents/rules/flutter.md](file:///.agents/rules/flutter.md)
- **Go Backend & Database**: [.agents/rules/golang.md](file:///.agents/rules/golang.md)
