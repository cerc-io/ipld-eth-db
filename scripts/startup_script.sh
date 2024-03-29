#!/bin/sh
# Runs the db migrations
set -e

# Default command is "goose up"
if [[ $# -eq 0 ]]; then
  set -- "up"
fi

# Construct the connection string for postgres
VDB_PG_CONNECT=postgresql://$DATABASE_USER:$DATABASE_PASSWORD@$DATABASE_HOSTNAME:$DATABASE_PORT/$DATABASE_NAME?sslmode=disable

# Run the DB migrations
echo "Connecting with: $VDB_PG_CONNECT"
echo "Running database migrations"
./goose -dir migrations postgres "$VDB_PG_CONNECT" "$@"

# If the db migrations ran without err
if [[ $? -eq 0 ]]; then
    echo "Migration process ran successfully"
else
    echo "Could not run migrations. Are the database details correct?"
    exit 1
fi
