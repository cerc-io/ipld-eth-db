ifndef GOPATH
override GOPATH = $(HOME)/go
endif

BIN = $(GOPATH)/bin

# Tools
## Migration tool
GOOSE = $(BIN)/goose
$(BIN)/goose:
	go get -u github.com/pressly/goose/cmd/goose

.PHONY: installtools
installtools: | $(GOOSE)
	echo "Installing tools"

#Database
HOST_NAME = localhost
PORT = 5432
NAME =
USER = postgres
PASSWORD = password
CONNECT_STRING=postgresql://$(USER):$(PASSWORD)@$(HOST_NAME):$(PORT)/$(NAME)?sslmode=disable

# Parameter checks
## Check that DB variables are provided
.PHONY: checkdbvars
checkdbvars:
	test -n "$(HOST_NAME)" # $$HOST_NAME
	test -n "$(PORT)" # $$PORT
	test -n "$(NAME)" # $$NAME
	@echo $(CONNECT_STRING)

## Check that the migration variable (id/timestamp) is provided
.PHONY: checkmigration
checkmigration:
	test -n "$(MIGRATION)" # $$MIGRATION

# Check that the migration name is provided
.PHONY: checkmigname
checkmigname:
	test -n "$(NAME)" # $$NAME

# Migration operations
## Rollback the last migration
.PHONY: rollback
rollback: $(GOOSE) checkdbvars
	$(GOOSE) -dir db/migrations postgres "$(CONNECT_STRING)" down
	pg_dump -O -s $(CONNECT_STRING) > schema.sql

## Rollback to a select migration (id/timestamp)
.PHONY: rollback_to
rollback_to: $(GOOSE) checkmigration checkdbvars
	$(GOOSE) -dir db/migrations postgres "$(CONNECT_STRING)" down-to "$(MIGRATION)"

## Rollback pre_batch_set
.PHONY: `rollback_pre_batch_set`
rollback_pre_batch_set: $(GOOSE) checkdbvars
	$(GOOSE) -dir db/pre_batch_processing_migrations postgres "$(CONNECT_STRING)" down

## Rollback post_batch_set
.PHONY: rollback_post_batch_set
rollback_post_batch_set: $(GOOSE) checkdbvars
	$(GOOSE) -dir db/post_batch_processing_migrations postgres "$(CONNECT_STRING)" down

## Apply the next up migration
.PHONY: migrate_up_by_one
migrate_up_by_one: $(GOOSE) checkdbvars
	$(GOOSE) -dir db/migrations postgres "$(CONNECT_STRING)" up-by-one

## Apply all migrations not already run
.PHONY: migrate
migrate: $(GOOSE) checkdbvars
	$(GOOSE) -dir db/migrations postgres "$(CONNECT_STRING)" up
	pg_dump -O -s $(CONNECT_STRING) > schema.sql

## Apply all the migrations used to generate a UML diagram (containing FKs)
.PHONY: migrate_for_uml
migrate_for_uml: $(GOOSE) checkdbvars
	$(GOOSE) -dir db/migrations/uml_support postgres "$(CONNECT_STRING)" up

## Apply migrations to be ran before a batch processing
.PHONY: migrate_pre_batch_set
migrate_pre_batch_set: $(GOOSE) checkdbvars
	$(GOOSE) -dir db/pre_batch_processing_migrations postgres "$(CONNECT_STRING)" up

## Apply migrations to be ran after a batch processing, one-by-one
.PHONY: migrate_post_batch_set_up_by_one
migrate_post_batch_set_up_by_one: $(GOOSE) checkdbvars
	$(GOOSE) -dir db/post_batch_processing_migrations postgres "$(CONNECT_STRING)" up-by-one

## Apply migrations to be ran after a batch processing
.PHONY: migrate_post_batch_set
migrate_post_batch_set: $(GOOSE) checkdbvars
	$(GOOSE) -dir db/post_batch_processing_migrations postgres "$(CONNECT_STRING)" up

## Create a new migration file
.PHONY: new_migration
new_migration: $(GOOSE) checkmigname
	$(GOOSE) -dir db/migrations create $(NAME) sql

## Check which migrations are applied at the moment
.PHONY: migration_status
migration_status: $(GOOSE) checkdbvars
	$(GOOSE) -dir db/migrations postgres "$(CONNECT_STRING)" status

# Convert timestamped migrations to versioned (to be run in CI);
# merge timestamped files to prevent conflict
.PHONY: version_migrations
version_migrations:
	$(GOOSE) -dir db/migrations fix

# Import a psql schema to the database
.PHONY: import
import:
	test -n "$(NAME)" # $$NAME
	psql $(NAME) < schema.sql

.PHONY: test-migrations
test-migrations: $(GOOSE)
	./scripts/test_migration.sh
