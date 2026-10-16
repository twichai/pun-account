NAME ?= migration
name ?= $(NAME)

.PHONY: migrate-status migrate-up migrate-down migrate-reset migrate-create

migrate-status:
	@$(MAKE) -C back-end migrate-status

migrate-up:
	@$(MAKE) -C back-end migrate-up

migrate-down:
	@$(MAKE) -C back-end migrate-down

migrate-reset:
	@$(MAKE) -C back-end migrate-reset

migrate-create:
	@$(MAKE) -C back-end migrate-create name="$(name)" NAME="$(NAME)"

# Handle colon notation like make migrate:create, make migrate:up, make migrate:status
migrate%:
	@target=$$(echo "$@" | tr ':' '-'); \
	$(MAKE) "$$target" name="$(name)" NAME="$(NAME)"
