-include .env
export

MIGRATION_DIR = db/migrations
DRIVER ?= postgres
DB_URL ?= $(DATABASE_URL)

NAME ?= migration
name ?= $(NAME)

.PHONY: migrate-status migrate-up migrate-down migrate-reset migrate-create

migrate-status:
	goose -dir $(MIGRATION_DIR) $(DRIVER) "$(DB_URL)" status

migrate-up:
	goose -dir $(MIGRATION_DIR) $(DRIVER) "$(DB_URL)" up

migrate-down:
	goose -dir $(MIGRATION_DIR) $(DRIVER) "$(DB_URL)" down

migrate-reset:
	goose -dir $(MIGRATION_DIR) $(DRIVER) "$(DB_URL)" reset

# Usage: make migrate-create [name=your_migration_name] or make migrate:create
migrate-create:
	goose -dir $(MIGRATION_DIR) create $(name) sql

# Handle colon notation like migrate:create, migrate:up, migrate:status
migrate%:
	@target=$$(echo "$@" | tr ':' '-'); \
	$(MAKE) "$$target" name="$(name)" NAME="$(NAME)"
