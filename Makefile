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

## Apply all migrations not already run
.PHONY: migrate
migrate: $(GOOSE) checkdbvars
	$(GOOSE) -dir db/migrations postgres "$(CONNECT_STRING)" up
	pg_dump -O -s $(CONNECT_STRING) > schema.sql

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


## Build docker image with schema
.PHONY: docker-build
docker-build:
	docker-compose build

## Build docker image for migration
.PHONY: docker-concise-migration-build
docker-concise-migration-build:
	docker build -t vulcanize/concise-migration-build -f ./db/Dockerfile .